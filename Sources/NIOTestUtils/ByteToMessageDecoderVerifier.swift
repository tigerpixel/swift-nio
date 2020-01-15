//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2019 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import NIO

public enum ByteToMessageDecoderVerifier {
    /// - seealso: verifyDecoder(inputOutputPairs:decoderFactory:)
    ///
    /// Verify `ByteToMessageDecoder`s with `String` inputs
    public static func verifyDecoder<Decoder: ByteToMessageDecoder>(stringInputOutputPairs: [(String, [Decoder.InboundOut])],
                                                                    decoderFactory: @escaping () -> Decoder) throws where Decoder.InboundOut: Equatable {
        let alloc = ByteBufferAllocator()
        let ioPairs = stringInputOutputPairs.map { (ioPair: (String, [Decoder.InboundOut])) -> (ByteBuffer, [Decoder.InboundOut]) in
            var buffer = alloc.buffer(capacity: ioPair.0.utf8.count)
            buffer.writeString(ioPair.0)
            return (buffer, ioPair.1)
        }
        return try ByteToMessageDecoderVerifier.verifyDecoder(inputOutputPairs: ioPairs, decoderFactory: decoderFactory)
    }

    /// Verifies a `ByteToMessageDecoder` by performing a number of tests.
    ///
    /// This method is mostly useful in unit tests for `ByteToMessageDecoder`s. It feeds the inputs from
    /// `inputOutputPairs` into the decoder in various ways and expects the decoder to produce the outputs from
    /// `inputOutputPairs`.
    ///
    /// The verification performs various tests, for example:
    ///
    ///  - drip feeding the bytes, one by one
    ///  - sending many messages in one `ByteBuffer`
    ///  - sending each complete message in one `ByteBuffer`
    ///
    /// For `ExampleDecoder` that produces `ExampleDecoderOutput`s you would use this method the following way:
    ///
    ///     var exampleInput1 = channel.allocator.buffer(capacity: 16)
    ///     exampleInput1.writeString("example-in1")
    ///     var exampleInput2 = channel.allocator.buffer(capacity: 16)
    ///     exampleInput2.writeString("example-in2")
    ///     let expectedInOuts = [(exampleInput1, [ExampleDecoderOutput("1")]),
    ///                           (exampleInput2, [ExampleDecoderOutput("2")])
    ///                          ]
    ///     XCTAssertNoThrow(try ByteToMessageDecoderVerifier.verifyDecoder(inputOutputPairs: expectedInOuts,
    ///                                                                     decoderFactory: { ExampleDecoder() }))
    public static func verifyDecoder<Decoder: ByteToMessageDecoder>(inputOutputPairs: [(ByteBuffer, [Decoder.InboundOut])],
                                                                    decoderFactory: @escaping () -> Decoder) throws where Decoder.InboundOut: Equatable {
        typealias Out = Decoder.InboundOut

        func verifySimple(channel: RecordingChannel) throws {
            for (input, expectedOutputs) in inputOutputPairs.shuffled() {
                try channel.writeInbound(input)
                for expectedOutput in expectedOutputs {
                    guard let actualOutput = try channel.readInbound(as: Out.self) else {
                        throw VerificationError<Out>(inputs: channel.inboundWrites,
                                                     errorCode: .underProduction(expectedOutput))
                    }
                    guard actualOutput == expectedOutput else {
                        throw VerificationError<Out>(inputs: channel.inboundWrites,
                                                     errorCode: .wrongProduction(actual: actualOutput,
                                                                                     expected: expectedOutput))
                    }
                }
                let actualExtraOutput = try channel.readInbound(as: Out.self)
                guard actualExtraOutput == nil else {
                    throw VerificationError<Out>(inputs: channel.inboundWrites,
                                                 errorCode: .overProduction(actualExtraOutput!))
                }
            }
        }

        func verifyDripFeed(channel: RecordingChannel) throws {
            for _ in 0..<10 {
                for (input, expectedOutputs) in inputOutputPairs.shuffled() {
                    for c in input.readableBytesView {
                        var buffer = channel.allocator.buffer(capacity: 12)
                        buffer.writeString("BEFORE")
                        buffer.writeInteger(c)
                        buffer.writeString("AFTER")
                        buffer.moveReaderIndex(forwardBy: 6)
                        buffer.moveWriterIndex(to: buffer.readerIndex + 1)
                        try channel.writeInbound(buffer)
                    }
                    for expectedOutput in expectedOutputs {
                        guard let actualOutput = try channel.readInbound(as: Out.self) else {
                            throw VerificationError<Out>(inputs: channel.inboundWrites,
                                                         errorCode: .underProduction(expectedOutput))
                        }
                        guard actualOutput == expectedOutput else {
                            throw VerificationError<Out>(inputs: channel.inboundWrites,
                                                         errorCode: .wrongProduction(actual: actualOutput,
                                                                                         expected: expectedOutput))
                        }
                    }
                    let actualExtraOutput = try channel.readInbound(as: Out.self)
                    guard actualExtraOutput == nil else {
                        throw VerificationError<Out>(inputs: channel.inboundWrites,
                                                     errorCode: .overProduction(actualExtraOutput!))
                    }
                }
            }
        }

        func verifyManyAtOnce(channel: RecordingChannel) throws {
            var overallBuffer = channel.allocator.buffer(capacity: 1024)
            var overallExpecteds: [Out] = []

            for _ in 0..<10 {
                for (var input, expectedOutputs) in inputOutputPairs.shuffled() {
                    overallBuffer.writeBuffer(&input)
                    overallExpecteds.append(contentsOf: expectedOutputs)
                }
            }

            try channel.writeInbound(overallBuffer)
            for expectedOutput in overallExpecteds {
                guard let actualOutput = try channel.readInbound(as: Out.self) else {
                    throw VerificationError<Out>(inputs: channel.inboundWrites,
                                                 errorCode: .underProduction(expectedOutput))
                }
                guard actualOutput == expectedOutput else {
                    throw VerificationError<Out>(inputs: channel.inboundWrites,
                                                 errorCode: .wrongProduction(actual: actualOutput,
                                                                                 expected: expectedOutput))
                }
            }
        }

        let decoder: Decoder = decoderFactory()
        let channel = RecordingChannel(EmbeddedChannel(handler: ByteToMessageHandler<Decoder>(decoder)))

        try verifySimple(channel: channel)
        try verifyDripFeed(channel: channel)
        try verifyManyAtOnce(channel: channel)

        if case .leftOvers(inbound: let ib, outbound: let ob, pendingOutbound: let pob) = try channel.finish() {
            throw VerificationError<Out>(inputs: channel.inboundWrites,
                                         errorCode: .leftOversOnDeconstructingChannel(inbound: ib,
                                                                                      outbound: ob,
                                                                                      pendingOutbound: pob))
        }
    }
}

extension ByteToMessageDecoderVerifier {
    private class RecordingChannel {
        private let actualChannel: EmbeddedChannel
        private(set) var inboundWrites: [ByteBuffer] = []

        init(_ actualChannel: EmbeddedChannel) {
            self.actualChannel = actualChannel
        }

        func readInbound<T>(as type: T.Type = T.self) throws -> T? {
            return try self.actualChannel.readInbound()
        }

        @discardableResult public func writeInbound(_ data: ByteBuffer) throws -> EmbeddedChannel.BufferState {
            self.inboundWrites.append(data)
            return try self.actualChannel.writeInbound(data)
        }

        var allocator: ByteBufferAllocator {
            return self.actualChannel.allocator
        }

        func finish() throws -> EmbeddedChannel.LeftOverState {
            return try self.actualChannel.finish()
        }
    }
}

extension ByteToMessageDecoderVerifier {
    /// A `VerificationError` is thrown when the verification of a `ByteToMessageDecoder` failed.
    public struct VerificationError<OutputType: Equatable>: Error {
        /// Contains the `inputs` that were passed to the `ByteToMessageDecoder` at the point where it failed
        /// verification.
        public var inputs: [ByteBuffer]

        /// `errorCode` describes the concrete problem that was detected.
        public var errorCode: ErrorCode

        public enum ErrorCode {
            /// The `errorCode` will be `wrongProduction` when the `expected` output didn't match the `actual`
            /// output.
            case wrongProduction(actual: OutputType, expected: OutputType)

            /// The `errorCode` will be set to `overProduction` when a decoding result was yielded where
            /// nothing was expected.
            case overProduction(OutputType)

            /// The `errorCode` will be set to `underProduction` when a decoder didn't yield output when output was
            /// expected. The expected output is delivered as the associated value.
            case underProduction(OutputType)

            /// The `errorCode` will be set to `leftOversOnDeconstructionChannel` if there were left-over items
            /// in the `Channel` on deconstruction. This usually means that your `ByteToMessageDecoder` did not process
            /// certain items.
            case leftOversOnDeconstructingChannel(inbound: [NIOAny], outbound: [NIOAny], pendingOutbound: [NIOAny])
        }
    }
}
