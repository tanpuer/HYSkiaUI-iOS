#pragma once

#include "YGConfig.h"
#include "PageStackManager.h"
#include "AssetManager.h"
#import "include/core/SkColorSpace.h"
#include "include/core/SkFontMgr.h"
#include "include/ports/SkFontMgr_mac_ct.h"
#include "skparagraph/include/TypefaceFontProvider.h"
#include "skparagraph/include/ParagraphBuilder.h"
#include "MeasureTime.h"

namespace HYSkiaUI {

struct TimerData {
    std::function<void()> callback;
    bool repeat;
    long delay;
    
    TimerData(std::function<void()>&& callback, bool repeat, long delay) {
        this->callback = std::move(callback);
        this->repeat = repeat;
        this->delay = delay;
    }
};

using namespace skia::textlayout;

class SkiaUIContext {
    
public:
    
    SkiaUIContext(NSThread *skiaUIThread) {
        this->_skiaUIThread = skiaUIThread;
        _config = YGConfigNew();
        this->intFont();
    }
    
    ~SkiaUIContext() {
        
    }
    
    const YGConfigRef getConfig() {
        return _config;
    }
    
    void setTimeMills(long time) {
        _currentTimeMills = time;
    }
    
    long getCurrentTimeMills() {
        return _currentTimeMills;
    }
    
    const std::shared_ptr<PageStackManager>& getPageStackManager() {
        return _pageStackManager;
    }
    
    std::shared_ptr<AssetManager>& getAssetManager() {
        return _assetManager;
    }
    
    void intFont() {
        MeasureTime("initFont");
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:nil];
        ALOGD("Bundle contents: %@", contents);
        auto fontMgr = SkFontMgr_New_CoreText(nullptr);
        auto fontProvider = sk_make_sp<TypefaceFontProvider>();
        {
            auto fontData = _assetManager->readImage("AlimamaFangYuanTiVF-Thin.ttf");
            auto data = SkData::MakeWithCopy(fontData->content, fontData->length);
            auto typeface = fontMgr->makeFromData(std::move(data));
            fontProvider->registerTypeface(typeface, SkString("Alimama"));
            delete fontData;
        }
        {
            auto fontData = _assetManager->readImage("NotoColorEmoji.ttf");
            auto data = SkData::MakeWithCopy(fontData->content, fontData->length);
            auto typeface = fontMgr->makeFromData(std::move(data));
            fontProvider->registerTypeface(typeface, SkString("ColorEmoji"));
            delete fontData;
        }
        {
            auto fontData = _assetManager->readImage("iconfont.woff");
            auto data = SkData::MakeWithCopy(fontData->content, fontData->length);
            iconFontTypeFace = fontMgr->makeFromData(std::move(data));
            delete fontData;
        }
        fontCollection = sk_make_sp<FontCollection>();
        fontCollection->setAssetFontManager(std::move(fontProvider));
        fontCollection->setDefaultFontManager(fontMgr);
        fontCollection->enableFontFallback();
    }
    
    sk_sp<FontCollection> getFontCollection() {
        return fontCollection;
    }
    
    sk_sp<SkTypeface> getIconFontTypeFace() {
        return iconFontTypeFace;
    }
    
    template<typename T>
    void runOnUIThread(std::function<T()> backgroundTask, std::function<void(T)> uiTask) {
        if (_skiaUIThread) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                T result = backgroundTask();
                void (^block)(void) = ^{
                    uiTask(result);
                };
                [block performSelector:@selector(invoke)
                              onThread:_skiaUIThread
                            withObject:nil
                         waitUntilDone:NO];
            });
        }
    }
    
    void sendToUIThread(std::function<void()> uiTask) {
        if (_skiaUIThread) {
            void (^block)(void) = ^{
                uiTask();
            };
            [block performSelector:@selector(invoke)
                          onThread:_skiaUIThread
                        withObject:nil
                     waitUntilDone:NO];
        }
    }
    
    void markDirty() {
        _dirty = true;
    }
    
    void clearDirty() {
        _dirty = false;
    }
    
    bool isDirty() {
        return _dirty;
    }
    
    long setTimer(std::function<void()>&& callback, long delay, bool repeat) {
        auto id = timerId++;
        _timerMap.emplace(id, TimerData(std::move(callback), repeat, delay));
        void (^block)(void) = ^{
            this->performTimer(id);
        };
        [block performSelector:@selector(invoke) withObject:nil afterDelay:(NSTimeInterval)(delay / 1000.0)];
        return id;
    }
    
    void clearTimer(long id) {
        if (_timerMap.find(id) != _timerMap.cend()) {
            _timerMap.erase(id);
        }
    }
    
    void performTimer(long id) {
        auto itr = _timerMap.find(id);
        if (itr != _timerMap.cend()) {
            auto timerData = itr->second;
            timerData.callback();
            if (!timerData.repeat) {
                return;
            }
            void (^block)(void) = ^{
                this->performTimer(id);
            };
            [block performSelector:@selector(invoke) withObject:nil afterDelay:(NSTimeInterval)(timerData.delay / 1000.0)];
        }
    }
    
private:
    
    long _currentTimeMills = 0L;
    
    YGConfigRef _config;
    
    std::shared_ptr<PageStackManager> _pageStackManager = std::make_shared<PageStackManager>();
    
    std::shared_ptr<AssetManager> _assetManager = std::make_shared<AssetManager>();
    
    sk_sp<SkFontMgr> fontMgr = nullptr;
    
    sk_sp<FontCollection> fontCollection = nullptr;
    
    sk_sp<SkTypeface> iconFontTypeFace = nullptr;
    
    NSThread *_skiaUIThread = nullptr;
    
    bool _dirty = true;
    
    std::unordered_map<long, TimerData> _timerMap;
    
    long timerId = 0L;
    
};

}
