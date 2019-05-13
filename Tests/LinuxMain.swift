//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2017-2018 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//
// LinuxMain.swift
//
import XCTest

///
/// NOTE: This file was generated by generate_linux_tests.rb
///
/// Do NOT edit this file directly as it will be regenerated automatically when needed.
///

#if os(Linux) || os(FreeBSD)
   @testable import NIOConcurrencyHelpersTests
   @testable import NIOHTTP1Tests
   @testable import NIOTLSTests
   @testable import NIOTestUtilsTests
   @testable import NIOTests
   @testable import NIOWebSocketTests

   XCTMain([
         testCase(AcceptBackoffHandlerTest.allTests),
         testCase(AdaptiveRecvByteBufferAllocatorTest.allTests),
         testCase(ApplicationProtocolNegotiationHandlerTests.allTests),
         testCase(Base64Test.allTests),
         testCase(BaseObjectTest.allTests),
         testCase(BlockingIOThreadPoolTest.allTests),
         testCase(BootstrapTest.allTests),
         testCase(ByteBufferTest.allTests),
         testCase(ByteBufferUtilsTest.allTests),
         testCase(ByteToMessageDecoderTest.allTests),
         testCase(ByteToMessageDecoderVerifierTest.allTests),
         testCase(ChannelNotificationTest.allTests),
         testCase(ChannelOptionStorageTest.allTests),
         testCase(ChannelPipelineTest.allTests),
         testCase(ChannelTests.allTests),
         testCase(CircularBufferTests.allTests),
         testCase(CustomChannelTests.allTests),
         testCase(DatagramChannelTests.allTests),
         testCase(EchoServerClientTest.allTests),
         testCase(EmbeddedChannelTest.allTests),
         testCase(EmbeddedEventLoopTest.allTests),
         testCase(EndToEndTests.allTests),
         testCase(EventLoopFutureTest.allTests),
         testCase(EventLoopTest.allTests),
         testCase(FileRegionTest.allTests),
         testCase(GetaddrinfoResolverTest.allTests),
         testCase(HTTPClientUpgradeTestCase.allTests),
         testCase(HTTPDecoderLengthTest.allTests),
         testCase(HTTPDecoderTest.allTests),
         testCase(HTTPHeadersTest.allTests),
         testCase(HTTPRequestEncoderTests.allTests),
         testCase(HTTPResponseEncoderTests.allTests),
         testCase(HTTPServerClientTest.allTests),
         testCase(HTTPServerPipelineHandlerTest.allTests),
         testCase(HTTPServerProtocolErrorHandlerTest.allTests),
         testCase(HTTPServerUpgradeTestCase.allTests),
         testCase(HTTPTest.allTests),
         testCase(HTTPTypesTest.allTests),
         testCase(HappyEyeballsTest.allTests),
         testCase(HeapTests.allTests),
         testCase(IdleStateHandlerTest.allTests),
         testCase(IntegerTypesTest.allTests),
         testCase(MarkedCircularBufferTests.allTests),
         testCase(MessageToByteEncoderTest.allTests),
         testCase(MulticastTest.allTests),
         testCase(NIOAnyDebugTest.allTests),
         testCase(NIOCloseOnErrorHandlerTest.allTests),
         testCase(NIOConcurrencyHelpersTests.allTests),
         testCase(NonBlockingFileIOTest.allTests),
         testCase(PendingDatagramWritesManagerTests.allTests),
         testCase(PriorityQueueTest.allTests),
         testCase(SNIHandlerTest.allTests),
         testCase(SelectorTest.allTests),
         testCase(SocketAddressTest.allTests),
         testCase(SocketChannelTest.allTests),
         testCase(SocketOptionProviderTest.allTests),
         testCase(SystemTest.allTests),
         testCase(ThreadTest.allTests),
         testCase(TypeAssistedChannelHandlerTest.allTests),
         testCase(UtilitiesTest.allTests),
         testCase(WebSocketFrameDecoderTest.allTests),
         testCase(WebSocketFrameEncoderTest.allTests),
    ])
#endif
