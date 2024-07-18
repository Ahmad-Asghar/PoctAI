import 'package:ai_chatbot/common/widgets/app_text_widget.dart';
import 'package:ai_chatbot/common/widgets/custom_main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/instance_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../common/app_colors.dart';
import '../common/widgets/custom_loading_indicator.dart';
import '../models/ask_gemini_model.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/java.dart';

class ChatBotScreen extends StatelessWidget {
   ChatBotScreen({super.key});

  TextEditingController askController= TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
     Get.put(AskGeminiController());
    return GetBuilder<AskGeminiController>(
        builder: (AskGeminiController controller) {
        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: CustomTextWidget(title: "Chat",fontSize: 5.w),
            actions: [
              Padding(
                padding:  EdgeInsets.only(right: 5.w),
                child: AnimatedContainer(
                  height: 4.5.h,
                  width:controller.conversationList.isNotEmpty?25.w:0,
                  duration: const Duration( milliseconds:700),
                  child: CustomMainButton(
                      color: AppColors.whiteColor,
                      elevation: 0,
                      borderColor: AppColors.primaryColor,
                      onTap: (){
                        if(!controller.isAsking.value){
                          controller.createNewChat();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              flex: 2,
                              child:controller.conversationList.isNotEmpty?Icon(Icons.add,size: 5.5.w,color: AppColors.primaryColor,):SizedBox()),
                          Expanded(
                              flex: 6,
                              child: CustomTextWidget(title: "New Chat",color: AppColors.primaryColor,fontSize: 13,maxLines: 1,)),

                        ],
                      )),
                ),
              )
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Divider(color: AppColors.dividerColor,),
            ),
          ),
          body: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 5.w),
            child:  Column(
              children: [
                controller.conversationList.isEmpty?
                Expanded(

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        height:28.h,
                        image: const AssetImage("assets/images/png/app_logo_p.png"),
                      ),
                      const SizedBox(height: 10,),
                      CustomTextWidget(
                        title: "Hi! You're One Search Away",
                        color: AppColors.greyTextColor,
                        fontSize: 4.5.w,
                        maxLines : 3,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.w600,
                      )
                    ],
                  ),
                )
                : Expanded(
                  child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.only(bottom: 7.h),
                      itemCount: controller.conversationList.length+1,
                      itemBuilder: (context,index){
                        if(index==controller.conversationList.length){
                          return controller.isAsking.value==true? const Align(
                              alignment: Alignment.centerLeft,
                              child:CustomGeminiLoadingIndicator()):const SizedBox();
                        }else{
                          return  Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              controller.conversationList[index].isQuestion?
                              Align(
                                alignment:Alignment.centerRight,
                                child: SizedBox(
                                  width: MediaQuery.sizeOf(context).width*0.7,
                                  child: Align(
                                    alignment:Alignment.centerRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding:  EdgeInsets.symmetric(horizontal: 4.w,vertical: 0.8.h),
                                        child: CustomTextWidget(title: controller.conversationList[index].text,color: AppColors.whiteColor,fontSize: 4.5.w,fontWeight: FontWeight.w600,),
                                      ),
                                    ),
                                  ),
                                ),
                              ):
                              controller.conversationList[index].isCodeAnswer==true?
                              Padding(
                                padding:  EdgeInsets.symmetric(vertical: 0.8.h),
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CodeTheme(
                                        data: CodeThemeData(
                                            styles: monokaiSublimeTheme),
                                        child: CodeField(
                                          decoration: BoxDecoration(
                                              color:AppColors.codePadColor,
                                              borderRadius: BorderRadius.circular(15)
                                          ),
                                          enabled:false,
                                          gutterStyle: const GutterStyle(
                                            showErrors: false,
                                            showFoldingHandles: false,
                                            showLineNumbers: false,
                                          ),
                                          controller:  CodeController(
                                            text: controller.conversationList[index].text,
                                            language: java,
                                          ),

                                        )),
                                    IconButton(
                                      onPressed:(){
                                        Clipboard.setData(ClipboardData(text: controller.conversationList[index].text));
                                        Fluttertoast.showToast(
                                            msg: "Copied to Clipboard",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: AppColors.blackColor,
                                            textColor: Colors.white,
                                            fontSize: 16.0
                                        );
                                      },
                                      icon: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: AppColors.whiteColor),
                                            color: AppColors.whiteColor.withOpacity(0.2)
                                        ),
                                        height: 30,
                                        width: 30,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Image(
                                            color:AppColors.whiteColor,
                                            image: const AssetImage('assets/images/png/copy.png',),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ):
                              CustomTextWidget(title: controller.conversationList[index].text,fontSize: 4.5.w,fontWeight: FontWeight.w600),
                              controller.conversationList[index].isQuestion==false? Divider(color: AppColors.dividerColor,):SizedBox(),

                            ],
                          );
                        }
                      }),
                ),
                Padding(
                  padding:  EdgeInsets.symmetric(vertical: 1.5.h),
                  child: Container(
                    height: 7.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: AppColors.dividerColor
                    ),

                    child: Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        children: [
                          Expanded(
                              child: TextFormField(
                                onTap: (){
                                  scrollToBottom();
                                },
                                controller:askController,
                                cursorHeight:20,
                                cursorRadius:const Radius.circular(20),
                                cursorColor:AppColors.greyTextColor,
                                style:GoogleFonts.poppins(
                                  color:AppColors.greyTextColor,
                                  fontSize:4.w,
                                ),
                                decoration: InputDecoration(
                                    hintText: 'Ask me anything...',
                                    hintStyle:GoogleFonts.poppins(
                                      color:AppColors.greyTextColor,
                                      fontSize:4.w,
                                    ),
                                    border: InputBorder.none
                                ),
                              )
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 15.w,
                            child: MaterialButton(
                              padding: EdgeInsets.zero,
                              height: 4.5.h,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              color:controller.isAsking.value==false? AppColors.primaryColor:Colors.grey,
                              onPressed: () async {
                                if(askController.text.trim().toString()!=""&&controller.isAsking.value==false){
                                  controller.askGemini(askController.text.trim().toString());
                                  askController.clear();
                                  scrollToBottom();

                                  //focusNode.unfocus();
                                }else{

                                  print("Empty Field");
                                }
                              },
                              child: CustomTextWidget(
                                title: "Send",
                                color: AppColors.whiteColor,
                                fontSize: 3.w,
                                maxLines : 1,
                                fontWeight: FontWeight.w600,
                              ),


                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}







class AskGeminiController extends GetxController {
  RxList<AskGeminiModel> conversationList = RxList<AskGeminiModel>();
  RxBool isAsking = false.obs;
  String apiKey = 'PASTE_YOUR_API_KEY_HERE';
  String? text;

  AskGeminiController({this.text});

  void askGemini(String questionText) async {
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    conversationList.add(
      AskGeminiModel(
        text: questionText,
        isQuestion: true,
        isCodeAnswer: false,
      ),
    );
    isAsking.value = true;
    update();
    print('Asked');
    final content = [Content.text(questionText)];
    try {
      final response = await model.generateContent(content);
      final responseText = response.text.toString();
      final isCode = responseText.startsWith('```') && responseText.endsWith('```');
      conversationList.add(
        AskGeminiModel(
          text: responseText,
          isQuestion: false,
          isCodeAnswer: isCode,
        ),
      );
    } catch (e) {
      conversationList.add(
        AskGeminiModel(
          text: "Something went wrong!...Check internet connection and try again...Thanks",
          isQuestion: false,
          isCodeAnswer: false,
        ),
      );
    }
    isAsking.value = false;
    update();
    print('Replied');
  }

  void createNewChat(){
    conversationList.clear();
    update();

  }
}
