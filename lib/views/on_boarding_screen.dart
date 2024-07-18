
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:svg_flutter/svg.dart';
import '../common/app_colors.dart';
import '../common/widgets/app_text_widget.dart';
import 'chatbot_screen.dart';
class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Container(

        color: AppColors.primaryColor.withOpacity(0.4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:  EdgeInsets.only(bottom: 25.h),
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height*0.4,
                child: PageView.builder(
                  itemCount: 3,
                    controller: OnBoardingController.pageController,
                    onPageChanged: (int index){
                      if(OnBoardingController.currentPage.value!=2){
                        OnBoardingController.currentPage.value=index;
                      }
                      OnBoardingController.secondPageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                      print("Page ${index}");
                    },
                    itemBuilder: (BuildContext context,int index){
                      return Image(
                        image: AssetImage('assets/images/png/onboarding$index.png'),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: SizedBox(
        height: 35.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 120,
              child: PageView.builder(
                controller: OnBoardingController.secondPageController,
                itemCount: 3,
                itemBuilder: (BuildContext context,int index){
                return Column(
                  children: [
                  CustomTextWidget(
                  title: OnBoardingController.onBoardingTitles[index],
                  color: AppColors.blackColor,
                  fontSize: 6.w,
                  maxLines : 1,
                    fontWeight: FontWeight.bold,
                  ),
                    const SizedBox(height: 7,),
                    CustomTextWidget(
                      title: OnBoardingController.onBoardingSubTitles[index],
                      color: Colors.grey.shade500,
                      fontSize: 5.w,
                      maxLines : 3,
                      textAlign: TextAlign.center,
                    )
                  ],
                );
              }
              ),
            ),
            SizedBox(height: 3.h,),
            Padding(
              padding: EdgeInsets.only(left: 5.w,right: 5.w,bottom: 2.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(()=> OnBoardingController.currentPage.value == 2 ?SizedBox():  Padding(
                      padding:  EdgeInsets.only(bottom:2.3.h),
                      child: SmoothPageIndicator(
                        controller: OnBoardingController.pageController,
                        count: 3,
                        effect: ExpandingDotsEffect(
                          expansionFactor: 4,
                          spacing: 5,
                          dotColor: Colors.grey.shade300,
                          dotWidth: 9,
                          dotHeight: 9,
                          activeDotColor: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  Obx(()=> AnimatedContainer(
                      width:OnBoardingController.currentPage.value == 2 ?(MediaQuery.sizeOf(context).width-10.w):50,
                      duration: const Duration( milliseconds:400),
                      child: MaterialButton(
                        height: 5.5.h,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)
                        ),
                          color: AppColors.primaryColor,
                          onPressed: () {
                            if(OnBoardingController.currentPage.value != 2){
                              int? currentPageIndex = OnBoardingController.pageController.page?.toInt();
                              int nextPageIndex = currentPageIndex! + 1;
                              if (nextPageIndex < 3) {
                                OnBoardingController.pageController.animateToPage(
                                  nextPageIndex,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                                OnBoardingController.secondPageController.animateToPage(
                                  nextPageIndex,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              }
                            }else{
                              Navigator.push(
                                context,
                                SlideTransitionPageRoute(page: ChatBotScreen()), // Replace ChatBotPage with the actual page you want to navigate to
                              );

                            }
                            print("Index ${OnBoardingController.currentPage.value}");
                          },
                          child: Padding(
                            padding:  EdgeInsets.symmetric(horizontal:OnBoardingController.currentPage.value == 2?4.w:0 ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (OnBoardingController.currentPage.value == 2)
                                  Expanded(
                                    child: Container(
                                      child: CustomTextWidget(
                                        title: "Get Started",
                                        color: AppColors.whiteColor,
                                        fontSize: 4.w,
                                        maxLines : 1,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                 SvgPicture.asset('assets/images/svg/right_arrow.svg'),
                              ],
                            ),
                          )


                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}







class OnBoardingController extends GetxController {
  static PageController pageController = PageController();
  static PageController secondPageController = PageController();
  static RxInt currentPage = 0.obs;

  static void changePage(int page) {
    currentPage.value=page;
    print("Curret page index is-- ${currentPage.value}");
  }

  static List<String> onBoardingTitles=[
    "Your AI Companion",
    "Learn and Grow",
    'Simplify Your Life',
  ];

  static List<String> onBoardingSubTitles=[
    "Advice, trivia, or a fun chat,\nyour AI companion is here\nAsk anything, anytime",
    "Expand your knowledge with AI\nGet facts and tutorials in seconds",
    "Quick answers and helpful insights\nJust a question away",
  ];
}




class SlideTransitionPageRoute extends PageRouteBuilder {
  final Widget page;

  SlideTransitionPageRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Slide from right to left
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

