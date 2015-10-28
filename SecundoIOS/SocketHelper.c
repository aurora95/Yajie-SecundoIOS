//
//  SocketHelper.c
//  SecundoIOS
//
//  Created by YajieXing on 15/10/24.
//  Copyright © 2015年 Yajie Xing. All rights reserved.
//

#include <stdio.h>
#include "SocketHelper.h"
#include <stdlib.h>
#include <unistd.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <netdb.h>
#include <strings.h>

struct sockaddr_in GetSockAddr(const char *hostname, int port)
{
    struct sockaddr_in serveraddr;
    struct hostent *hp;
    hp = gethostbyname(hostname);
    serveraddr.sin_family = AF_INET;
    bcopy((char *)hp->h_addr_list[0],
          (char *)&serveraddr.sin_addr.s_addr, hp->h_length);
    serveraddr.sin_port = htons(port);
    return serveraddr;
}

const unsigned char* TransSockAddrToBytes(struct sockaddr_in *serveraddr)
{
    return (unsigned char*)serveraddr;
}

int SizeOfSockAddr(){
    return sizeof(struct sockaddr_in);
}