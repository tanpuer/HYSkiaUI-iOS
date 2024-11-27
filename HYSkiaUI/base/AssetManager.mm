#include "AssetManager.h"
#import "Foundation/Foundation.h"

AssetManager::AssetManager() {
    
}

char *AssetManager::readFile(const char *path) {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:path] ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSUInteger length = [data length];
    char* buffer = (char*)malloc(length + 1);
    memcpy(buffer, [data bytes], length);
    buffer[length] = '\0';
    return buffer;
}

ImageData *AssetManager::readImage(const char *path) {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:path] ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSUInteger length = [data length] + 1;
    char* buffer = (char*)malloc(length);
    memcpy(buffer, [data bytes], length - 1);
    buffer[length] = '\0';
    auto imageData = new ImageData();
    imageData->length = data.length;
    imageData->content = buffer;
    return imageData;
}

ImageData *AssetManager::readImage(const char *name, const char *type, const char *dir) {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:name] ofType:[NSString stringWithUTF8String:type] inDirectory:[NSString stringWithUTF8String:dir]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSUInteger length = [data length];
    char* buffer = (char*)malloc(length + 1);
    memcpy(buffer, [data bytes], length);
    buffer[length] = '\0';
    auto imageData = new ImageData();
    imageData->length = data.length;
    imageData->content = buffer;
    return imageData;
}
