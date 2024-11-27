#pragma once

#define JNI_DEBUG 1
#define JNI_TAG "HYSkiaUI"

#ifdef Android
#include <android/log.h>
#define ALOGE(format, ...) if (JNI_DEBUG) { __android_log_print(ANDROID_LOG_ERROR, JNI_TAG, format, ##__VA_ARGS__); }
#define ALOGI(format, ...) if (JNI_DEBUG) { __android_log_print(ANDROID_LOG_INFO,  JNI_TAG, format, ##__VA_ARGS__); }
#define ALOGD(format, ...) if (JNI_DEBUG) { __android_log_print(ANDROID_LOG_DEBUG, JNI_TAG, format, ##__VA_ARGS__); }
#define ALOGW(format, ...) if (JNI_DEBUG) { __android_log_print(ANDROID_LOG_WARN,  JNI_TAG, format, ##__VA_ARGS__); }
#else
#import <Foundation/Foundation.h>
#define ALOGE(format, ...) if (JNI_DEBUG) { NSLog(@"[ERROR][%s] " format, JNI_TAG, ##__VA_ARGS__); }
#define ALOGI(format, ...) if (JNI_DEBUG) { NSLog(@"[INFO][%s] " format, JNI_TAG, ##__VA_ARGS__); }
#define ALOGD(format, ...) if (JNI_DEBUG) { NSLog(@"[DEBUG][%s] " format, JNI_TAG, ##__VA_ARGS__); }
#define ALOGW(format, ...) if (JNI_DEBUG) { NSLog(@"[WARN][%s] " format, JNI_TAG, ##__VA_ARGS__); }
#endif