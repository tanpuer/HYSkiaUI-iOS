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
    
    const std::shared_ptr<PageStackManager> getPageStackManager() {
        return _pageStackManager;
    }
    
    std::shared_ptr<AssetManager> getAssetManager() {
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
    
    void runOnMainThread(std::function<void()> func) {
        dispatch_async(dispatch_get_main_queue(), ^{
            func();
        });
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
    
    
private:
    
    long _currentTimeMills = 0L;
    
    YGConfigRef _config;
    
    std::shared_ptr<PageStackManager> _pageStackManager = std::make_shared<PageStackManager>();
    
    std::shared_ptr<AssetManager> _assetManager = std::make_shared<AssetManager>();
    
    sk_sp<SkFontMgr> fontMgr = nullptr;
    
    sk_sp<FontCollection> fontCollection = nullptr;
    
    sk_sp<SkTypeface> iconFontTypeFace = nullptr;
    
    NSThread *_skiaUIThread = nullptr;
    
};

}
