https://github.com/tanpuer/SkiaUI2 for iOS

Just a git commit, just for fun, no further development.

steps：

1. Using Skia Metal context.
2. Two threads: ui-thread & render-thread.
3. Only support FlexboxLayout. Measure/Layout/Draw are triggered by Vsync.
4. TouchEvents: dispatchTouchEvent/interceptTouchEvent/onTouchEvent.
5. Animations support scale/rotate/translate，the interpolator will be executed in Layout then update SkRect.
6. Supported Widgets:   
   View: rect, cornerRadius.  
   ImageView: support png/gif, scaleType，cornerRadius, blur.  
   TextView: use SkParagraph, use AlimamaFangYuanTiVF-Thin.ttf by default.  
   Icon: use the iconfont.woff by default.  
   ProgressBar: circle and linear style，also can be dragged.  
   SVGView: svg file.  
   ShaderView: render simple fragment-shader.  
   Lottie: render lottie.json.  
   YUVVideoView: render video by AVFoundation/SkRuntimeEffect.  
   LyricView: parse .srt files, use RecyclerView to render lyric.  
   MovingArea: intercept TouchEvents by default and can move.  
   Swiper: just like ViewPager.  
   Other CustomsViews: Loading, Switch, Radio, Picker...  
   PlatformView: TODO!!!  
   ...
8. scrollView: scroll, fling，for more optimizations.
9. RecyclerView: adapter，ViewHolder，for more optimizations.
10. Page: act as the same role as Activity.
11. C++: See CppTest.cpp.
14. Dirty-Render: markDirty after "draw" if necessary.

![image](https://github.com/tanpuer/HYSkiaUI-iOS/blob/main/example1.jpeg)
![image](https://github.com/tanpuer/HYSkiaUI-iOS/blob/main/example2.jpeg)
![image](https://github.com/tanpuer/HYSkiaUI-iOS/blob/main/example3.jpeg)

