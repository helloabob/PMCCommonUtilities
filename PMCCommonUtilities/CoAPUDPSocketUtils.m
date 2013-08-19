//
//  CoAPUDPSocketUtils.m
//  PMCCommonUtilities
//
//  Created by wangbo on 13-8-14.
//  Copyright (c) 2013年 wangbo. All rights reserved.
//

#import "CoAPUDPSocketUtils.h"

#import "sys/socket.h"
#import "netinet/in.h"

@implementation CoAPUDPSocketUtils

+ (NSString *)sendMessageWithData:(NSData *)data withIP:(NSString *)ip isResponse:(BOOL)isResponse{
    NSLog(@"ip:%@ data:%@", ip, data);
    int sockfd;
    sockfd = socket(AF_INET,SOCK_DGRAM,0);
    if(sockfd< 0){
        NSLog(@"error in creating socket:%d.",sockfd);
        return nil;
    }
    struct sockaddr_in addr;
    char buffer[256];
    memset(buffer, 0, 256);
//    buffer[0] = 0x43;
//    buffer[1] = 0x01;
//    buffer[2] = 0x27;
//    buffer[3] = 0x10;
//    buffer[4] = 0x91;
//    buffer[5] = 0x6C;
//    buffer[6] = 0x01;
//    buffer[7] = 0x30;
//    
//    buffer[8] = 0x01;
//    buffer[9] = 0x73;
    
    //    char *point = (char *)(buffer+8);
    //    strcpy(point, payload);
    const char *msg = [data bytes];
    bzero(&addr, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(5683);
    addr.sin_addr.s_addr = inet_addr([ip UTF8String]);
    int res = sendto(sockfd,msg,strlen(msg),0,(struct sockaddr *)&addr,sizeof(addr));
    if (res == -1) {
        NSLog(@"error in sendto");
    }
    
    if (!isResponse) {
        close(sockfd);
        return nil;
    }
    
    memset(buffer, 0, 255);
    //    printf("buffer%s",buffer);
    
    socklen_t addr_len = sizeof(addr);
    
    //    res = recvfrom(sockfd, buffer, 255, 0, (struct sockaddr *)&addr, &addr_len);
    
    struct timeval tv;
    fd_set readfds;
    FD_ZERO(&readfds);
    FD_SET(sockfd, &readfds);
    tv.tv_sec = 1;
    tv.tv_usec = 1;
    select(sockfd+1, &readfds, NULL, NULL, &tv);
    if (FD_ISSET(sockfd, &readfds)) {
        if ((res = recvfrom(sockfd, buffer, 255, 0, (struct sockaddr *)&addr, &addr_len)) >= 0) {
        }
    }
    printf("buffer:%s",buffer);
    
    //    free(buffer);
    //    point = NULL;
    close(sockfd);
    return [NSString stringWithFormat:@"%s", buffer];
    
}

@end
