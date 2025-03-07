# SkiaUI

Using Skia, Yoga to build a simple Flexbox-UI framework for iOS.

steps：

1. Compile skia https://skia.org/docs/user/build/
2. Using Skia Metal context.
3. Two threads: ui-thread & render-thread.
4. Only support FlexboxLayout. Measure/Layout/Draw are triggered by Vsync.
5. TouchEvents: dispatchTouchEvent/interceptTouchEvent/onTouchEvent.
6. TouchEvents: dispatchTouchEvent/interceptTouchEvent/onTouchEvent.
7. Animations support scale/rotate/translate，and will be performed before measure.
8. Dirty-Render: markDirty if next draw is necessary.
9. **Supported Widgets**:   
   View, ImageView, TextView, Icon, ProgressBar, SVGView, ShaderView, Lottie,
   YUVVideoView, ScrollView, MovingArea, RecyclerView, Swiper, Loading, Switch, Radio, Picker,
   LyricView, FlexboxLayout, Page...
10. **PlatformView**:  
   TODO!
11. **Development**:  
    C++: See CppTest.cpp.  
    **React**: https://github.com/tanpuer/skia-ui-react.  
    SwiftUI: TODO!  
12. **Cross Platform**  
    Android: https://github.com/tanpuer/SkiaUI2   

![image](https://github.com/tanpuer/HYSkiaUI-iOS/blob/main/example1.jpeg)
![image](https://github.com/tanpuer/HYSkiaUI-iOS/blob/main/example2.jpeg)
![image](https://github.com/tanpuer/HYSkiaUI-iOS/blob/main/example3.jpeg)

