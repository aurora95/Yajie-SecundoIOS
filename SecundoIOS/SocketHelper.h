//
//  SocketHelper.h
//  SecundoIOS
//
//  Created by YajieXing on 15/10/23.
//  Copyright © 2015年 Yajie Xing. All rights reserved.
//

#ifndef SocketHelper_h
#define SocketHelper_h

#include <stdlib.h>
#include <unistd.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <netdb.h>

struct sockaddr_in GetSockAddr(const char *hostname, int port);

const unsigned char* TransSockAddrToBytes(struct sockaddr_in *serveraddr);

int SizeOfSockAddr();

#endif /* SocketHelper_h */
