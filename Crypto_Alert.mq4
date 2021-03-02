//------------------------------------------------------------------
#property copyright ""
#property link      ""
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 12
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrPaleVioletRed
#property indicator_color3  clrLimeGreen
#property indicator_color4  clrPaleVioletRed
#property indicator_color5  clrLimeGreen
#property indicator_color6  clrPaleVioletRed
#property indicator_color7  clrLimeGreen
#property indicator_color8  clrPaleVioletRed
#property indicator_color9  clrLimeGreen
#property indicator_color10  clrPaleVioletRed
#property indicator_color11  clrLimeGreen   //
#property indicator_color12  clrPaleVioletRed //
#property indicator_minimum 0
#property indicator_maximum 7

//#define UpSymbol    "\x2191"
//#define DownSymbol  "\x2193"

// #include <Telegram.mqh>
#include <mql4-http.mqh>

enum TimeFrameType
  {
   Current_time_frame,
   M1,
   M5,
   M15,
   M30,
   H1,
   H4,
   D1,
   W1,
   MN
  };

enum NextType
  {
   next1,
   next2,
   next3,
   next4,
   next5,
   next6,
   next7,
   next8,
   next9      
  };



extern string TimeFrame1                          = "Current time frame";
extern string TimeFrame2                          = "next1";
extern string TimeFrame3                          = "next2";
extern string TimeFrame4                          = "next3";
extern string TimeFrame5                          = "next4";
extern string TimeFrame6                          = "next5";



//extern string note1="----------------------------------------------"; do not put this line here; strange; will crash
extern int    Sensitive                           = 150;
extern string note2="----------------------------------------------";//----------------------------------------------
extern int    LinesWidth                          = 0;
extern color  LabelsColor                         = clrDarkGray;
extern int    LabelsHorizontalShift               = 5;
extern double LabelsVerticalShift                 = 1.5;
extern string note3="----------------------------------------------";//----------------------------------------------
extern bool   alertsOn                            = true;
extern bool   TrendContinousAlertOn               = true; //Trend Continous Alert
extern bool   ReversalAlertOn                     = true; //Reversal Alert
extern int    alertsHowManyTimeFrameAligned       = 5;  //Minimal Frame Aligned
extern bool    alertsTelegram                     = true;
extern bool    alertsNotify                       = false;
extern bool   alertsMessage                       = false;
extern bool   alertsSound                         = false;
extern bool   alertsEmail                         = false;
extern string BotToken = "1607203450:AAFK_DfayctvtyTVXU0qcupS2O5maNtTwco";
extern string ChatID =   "-1001488517188"; //Need neg -100
//extern string BotToken = "1633848369:AAG7i5JKhaWjTulAca1OeA6P_CiAW0lNwDo";
//extern string ChatID = "-1001388614213"; //HardTrend
//extern string BotToken = "1633848369:AAG7i5JKhaWjTulAca1OeA6P_CiAW0lNwDo";
//extern string ChatID = "-1001388614213";
extern string note3a="----------------------------------------------";//----------------------------------------------
extern int    alertsExitHowManyTimeFrameAlignedMin       = 2;  //
extern int    alertsExitHowManyTimeFrameAlignedMax       = 3;  //
extern string note4="----------------------------------------------";//----------------------------------------------
extern bool   ATROn                            = true;
extern int ATRPeriod                           = 7;
extern string note4a="----------------------------------------------";//----------------------------------------------
extern bool   ADIOn                            = true;
extern int ADIPeriod                           = 7;
extern string note4b="----------------------------------------------";//----------------------------------------------
extern bool   DisplayArrows                       = true;
extern int    DrawArrowsWhenTimeFrameAligned      = 5; //
extern int    ArrowGap                            = 1; 
extern int    ArrowWidth                          = 1;
extern int    UpArrowWingDingsFontCode            = 221;
extern int    DownArrowWingDingsFontCode          = 222;
extern color  UpArrowColor                        = clrGreenYellow;
extern color  DownArrowColor                      = clrRed;
extern string note5="----------------------------------------------";//----------------------------------------------
extern int    TimeFrame1WingdingsFontCode         = 110;
extern int    TimeFrame2WingdingsFontCode         = 108;
extern int    TimeFrame3WingdingsFontCode         = 108;
extern int    TimeFrame4WingdingsFontCode         = 108;
extern int    TimeFrame5WingdingsFontCode         = 108;
extern int    TimeFrame6WingdingsFontCode         = 108; //
extern string    ProductID                        = "HardTrend";
extern string UniqueID                            = "Davidis";
extern int    MaximumCandlesToDisplay             = 1000;
string UpSymbol                           = "\x2191";
string DownSymbol                         = "\x2193"; 
//  = "↑"; // = "↓";                     
//extern string note6="----------------------------------------------";//----------------------------------------------

double trends[], ForexStation1Up[], ForexStation1Down[], ForexStation2Up[], ForexStation2Down[], ForexStation3Up[], ForexStation3Down[], ForexStation4Up[], ForexStation4Down[], ForexStation5Up[], ForexStation5Down[], ForexStation6Up[], ForexStation6Down[]; //

int    timeFrames[6]; //
bool   returnBars, calculateValue;
string indicatorFileName;
int LastEnterUp,LastEnterDown,LastExitUp,LastExitDown;
bool Last3Up,Last3Down,Last4Up,Last4Down,Last2Up,Last2Down;
string candles, LastDirection;
int Upsignalstrength, Downsignalstrength;
bool DownLevel1, DownLevel2, DownLevel3, DownLevel4, DownLevel5, DownLevel6, UpLevel1, UpLevel2, UpLevel3, UpLevel4, UpLevel5, UpLevel6;
datetime now;
datetime timeoffset=D'1970.1.1 00:00:00';
int timezone;

// CCustomBot bot;

//------------------------------------------------------------------
int OnInit()
{
   IndicatorBuffers(13);
   
   SetIndexBuffer(0,ForexStation1Up);
   SetIndexBuffer(1,ForexStation1Down);
   SetIndexBuffer(2,ForexStation2Up);
   SetIndexBuffer(3,ForexStation2Down);
   SetIndexBuffer(4,ForexStation3Up);
   SetIndexBuffer(5,ForexStation3Down);
   SetIndexBuffer(6,ForexStation4Up);
   SetIndexBuffer(7,ForexStation4Down);
   SetIndexBuffer(8,ForexStation5Up);
   SetIndexBuffer(9,ForexStation5Down);
   SetIndexBuffer(10,ForexStation6Up);
   SetIndexBuffer(11,ForexStation6Down);        
   SetIndexBuffer(12,trends);
   
      indicatorFileName = WindowExpertName();
      returnBars        = (TimeFrame1=="returnBars");     if (returnBars)     return(0);
      calculateValue    = (TimeFrame1=="calculateValue"); if (calculateValue) return(0);
      
      SetIndexStyle(0,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(0,TimeFrame1WingdingsFontCode); 
      SetIndexStyle(1,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(1,TimeFrame1WingdingsFontCode); 
      SetIndexStyle(2,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(2,TimeFrame2WingdingsFontCode); 
      SetIndexStyle(3,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(3,TimeFrame2WingdingsFontCode); 
      SetIndexStyle(4,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(4,TimeFrame3WingdingsFontCode); 
      SetIndexStyle(5,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(5,TimeFrame3WingdingsFontCode); 
      SetIndexStyle(6,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(6,TimeFrame4WingdingsFontCode); 
      SetIndexStyle(7,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(7,TimeFrame4WingdingsFontCode); 
      SetIndexStyle(8,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(8,TimeFrame5WingdingsFontCode); 
      SetIndexStyle(9,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(9,TimeFrame5WingdingsFontCode); 
      SetIndexStyle(10,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(10,TimeFrame6WingdingsFontCode);  //
      SetIndexStyle(11,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(11,TimeFrame6WingdingsFontCode);    //   
      
      
      timeFrames[0] = stringToTimeFrame(TimeFrame1);
      timeFrames[1] = stringToTimeFrame(TimeFrame2);
      timeFrames[2] = stringToTimeFrame(TimeFrame3);
      timeFrames[3] = stringToTimeFrame(TimeFrame4);
      timeFrames[4] = stringToTimeFrame(TimeFrame5);   
      timeFrames[5] = stringToTimeFrame(TimeFrame6);            //
     // alertsHowManyTimeFrameAligned = MathMin(MathMax(alertsHowManyTimeFrameAligned,2),6);
      alertsHowManyTimeFrameAligned = MathMin(MathMax(alertsHowManyTimeFrameAligned,2),ArraySize(timeFrames)); //
   // alertsHowManyTimeFrameAligned =2;
      IndicatorShortName(UniqueID);
      
      now = TimeLocal();
      
   return(0);
}
//------------------------------------------------------------------
int deinit()
{
   for (int t=0; t<6; t++) ObjectDelete(UniqueID+t); //
   for (int i = ObjectsTotal()-1; i >= 0; i--)   
   if (StringSubstr(ObjectName(i), 0, StringLen(UniqueID)) == UniqueID)
       ObjectDelete(ObjectName(i)); 
   return(0); 
}
//------------------------------------------------------------------
double trend[][2];
#define _up 0
#define _dn 1
int start()
{


   timezone = GetTimeZone();
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (limit>MaximumCandlesToDisplay) limit = MaximumCandlesToDisplay;
         if (returnBars)     { ForexStation1Up[0] = limit+1;  return(0); }
         

         if (timeFrames[0] != Period()) limit = MathMax(limit,MathMin(MaximumCandlesToDisplay,iCustom(NULL,timeFrames[0],indicatorFileName,"returnBars",0,0)*timeFrames[0]/Period()));
         if (timeFrames[1] != Period()) limit = MathMax(limit,MathMin(MaximumCandlesToDisplay,iCustom(NULL,timeFrames[1],indicatorFileName,"returnBars",0,0)*timeFrames[1]/Period()));
         if (timeFrames[2] != Period()) limit = MathMax(limit,MathMin(MaximumCandlesToDisplay,iCustom(NULL,timeFrames[2],indicatorFileName,"returnBars",0,0)*timeFrames[2]/Period()));
         if (timeFrames[3] != Period()) limit = MathMax(limit,MathMin(MaximumCandlesToDisplay,iCustom(NULL,timeFrames[3],indicatorFileName,"returnBars",0,0)*timeFrames[3]/Period()));
         if (timeFrames[4] != Period()) limit = MathMax(limit,MathMin(MaximumCandlesToDisplay,iCustom(NULL,timeFrames[4],indicatorFileName,"returnBars",0,0)*timeFrames[4]/Period()));
         if (timeFrames[5] != Period()) limit = MathMax(limit,MathMin(MaximumCandlesToDisplay,iCustom(NULL,timeFrames[5],indicatorFileName,"returnBars",0,0)*timeFrames[5]/Period()));  // 
         
         
         if (ArrayRange(trend,0)!=Bars) ArrayResize(trend,Bars);
        
         static bool initialized = false;
         int t1=0;
         if (!initialized)
         {
            initialized = true;
            int window = WindowFind(UniqueID);
            for (t1=0; t1<6; t1++) //
            {
               string label = timeFrameToString(timeFrames[t1]);
               ObjectCreate(UniqueID+t1,OBJ_TEXT,window,0,0);
               ObjectSet(UniqueID+t1,OBJPROP_COLOR,LabelsColor);
               ObjectSet(UniqueID+t1,OBJPROP_PRICE1,t1+LabelsVerticalShift);
               ObjectSetText(UniqueID+t1,label,7,"Arial");
            }               
         }
         for (t1=0; t1<6; t1++) ObjectSet(UniqueID+t1,OBJPROP_TIME1,Time[0]+Period()*LabelsHorizontalShift*60); //

   //
   //
   //
   //
   //
    
    
     
   for(i = limit, r=Bars-i-1; i >= 0; i--,r++)
   {
      trend[r][_up] = 0;
      trend[r][_dn] = 0;
      candles = "";
      Upsignalstrength = Downsignalstrength = 0;
      DownLevel1 = DownLevel2 = DownLevel3 = DownLevel4 = DownLevel5 = UpLevel1 = UpLevel2 = UpLevel3 = UpLevel4 = UpLevel5 =false;      
      for (int k=0; k<6; k++) //
      {
         int    y      = iBarShift(NULL,timeFrames[k],Time[i]);
         double trend1 = (iMACD(NULL,timeFrames[k],20,40,9,PRICE_CLOSE,MODE_MAIN,y)-
                          iMACD(NULL,timeFrames[k],20,40,9,PRICE_CLOSE,MODE_MAIN,y+1))*Sensitive;
         bool   isUp   = (trend1>0);
          
         switch (k)
         {
            case 0 : if (isUp) { ForexStation1Up[i] = k+1; ForexStation1Down[i] = EMPTY_VALUE; candles = candles+UpSymbol; Upsignalstrength += MathPow(2,k); UpLevel1=true;}  else { ForexStation1Down[i] = k+1; ForexStation1Up[i] = EMPTY_VALUE; candles = candles+DownSymbol; Downsignalstrength += MathPow(2,k); DownLevel1=true; }break;
            case 1 : if (isUp) { ForexStation2Up[i] = k+1; ForexStation2Down[i] = EMPTY_VALUE; candles = candles+UpSymbol; Upsignalstrength += MathPow(2,k); UpLevel2=true; }  else { ForexStation2Down[i] = k+1; ForexStation2Up[i] = EMPTY_VALUE; candles = candles+DownSymbol; Downsignalstrength += MathPow(2,k); DownLevel2=true;} break;
            case 2 : if (isUp) { ForexStation3Up[i] = k+1; ForexStation3Down[i] = EMPTY_VALUE; candles = candles+UpSymbol; Upsignalstrength += MathPow(2,k); UpLevel3=true; }  else { ForexStation3Down[i] = k+1; ForexStation3Up[i] = EMPTY_VALUE; candles = candles+DownSymbol; Downsignalstrength += MathPow(2,k); DownLevel3=true;} break;
            case 3 : if (isUp) { ForexStation4Up[i] = k+1; ForexStation4Down[i] = EMPTY_VALUE; candles = candles+UpSymbol; Upsignalstrength += MathPow(2,k); UpLevel4=true; }  else { ForexStation4Down[i] = k+1; ForexStation4Up[i] = EMPTY_VALUE; candles = candles+DownSymbol; Downsignalstrength += MathPow(2,k); DownLevel4=true;} break;      
            case 4 : if (isUp) { ForexStation5Up[i] = k+1; ForexStation5Down[i] = EMPTY_VALUE; candles = candles+UpSymbol; Upsignalstrength += MathPow(2,k); UpLevel5=true;}  else { ForexStation5Down[i] = k+1; ForexStation5Up[i] = EMPTY_VALUE; candles = candles+DownSymbol; Downsignalstrength += MathPow(2,k);DownLevel5=true;} break;
            case 5 : if (isUp) { ForexStation6Up[i] = k+1; ForexStation6Down[i] = EMPTY_VALUE; candles = candles+UpSymbol; Upsignalstrength += MathPow(2,k); UpLevel6=true;}  else { ForexStation6Down[i] = k+1; ForexStation6Up[i] = EMPTY_VALUE; candles = candles+DownSymbol; Downsignalstrength += MathPow(2,k);DownLevel6=true;} break; // 
         }
         if (isUp)
                  trend[r][_up] += 1;
            else  trend[r][_dn] += 1;
      }
     
     trends[i]=trends[i+1];
     
   
//====     
           if (DrawArrowsWhenTimeFrameAligned == 6) //
        {
         if(trends[i]!=1 && ForexStation1Up[i]!=EMPTY_VALUE && ForexStation2Up[i]!=EMPTY_VALUE && ForexStation3Up[i]!=EMPTY_VALUE && ForexStation4Up[i]!=EMPTY_VALUE && ForexStation5Up[i]!=EMPTY_VALUE && ForexStation6Up[i]!=EMPTY_VALUE) 
         {
           trends[i] = 1;
           if (DisplayArrows) arrows_wind(i,"Up",ArrowGap ,UpArrowWingDingsFontCode,UpArrowColor,ArrowWidth,false);   
           }else{
           ObjectDelete(UniqueID+"Up"+TimeToStr(Time[i]));
         } 
         if(trends[i]!=-1 && ForexStation1Down[i]!=EMPTY_VALUE && ForexStation2Down[i]!=EMPTY_VALUE && ForexStation3Down[i]!=EMPTY_VALUE && ForexStation4Down[i]!=EMPTY_VALUE && ForexStation5Down[i]!=EMPTY_VALUE && ForexStation6Down[i]!=EMPTY_VALUE) 
         {
           trends[i] =-1;
           if (DisplayArrows) arrows_wind(i,"Dn",ArrowGap ,DownArrowWingDingsFontCode,DownArrowColor,ArrowWidth,true);
           }else{
           ObjectDelete(UniqueID + "Dn" + TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
           }  
           if(trends[i]== 1 && (ForexStation1Up[i]  ==EMPTY_VALUE || ForexStation2Up[i]  ==EMPTY_VALUE || ForexStation3Up[i]  ==EMPTY_VALUE || ForexStation4Up[i]  ==EMPTY_VALUE || ForexStation5Up[i]  ==EMPTY_VALUE || ForexStation6Up[i]  ==EMPTY_VALUE)) trends[i] = 0;
           if(trends[i]==-1 && (ForexStation1Down[i]==EMPTY_VALUE || ForexStation2Down[i]==EMPTY_VALUE || ForexStation3Down[i]==EMPTY_VALUE || ForexStation4Down[i]==EMPTY_VALUE || ForexStation5Down[i]==EMPTY_VALUE || ForexStation6Down[i]==EMPTY_VALUE)) trends[i] = 0;
         }  //      if (alertsHowManyTimeFrameAligned == 6)
     else     
//====        
     
     
          if (DrawArrowsWhenTimeFrameAligned == 5)
        {
         if(trends[i]!=1 && ForexStation1Up[i]!=EMPTY_VALUE && ForexStation2Up[i]!=EMPTY_VALUE && ForexStation3Up[i]!=EMPTY_VALUE && ForexStation4Up[i]!=EMPTY_VALUE && ForexStation5Up[i]!=EMPTY_VALUE) 
         {
           trends[i] = 1;
           if (DisplayArrows) arrows_wind(i,"Up",ArrowGap ,UpArrowWingDingsFontCode,UpArrowColor,ArrowWidth,false);   
           }else{
           ObjectDelete(UniqueID+"Up"+TimeToStr(Time[i]));
         } 
         if(trends[i]!=-1 && ForexStation1Down[i]!=EMPTY_VALUE && ForexStation2Down[i]!=EMPTY_VALUE && ForexStation3Down[i]!=EMPTY_VALUE && ForexStation4Down[i]!=EMPTY_VALUE && ForexStation5Down[i]!=EMPTY_VALUE) 
         {
           trends[i] =-1;
           if (DisplayArrows) arrows_wind(i,"Dn",ArrowGap ,DownArrowWingDingsFontCode,DownArrowColor,ArrowWidth,true);
           }else{
           ObjectDelete(UniqueID + "Dn" + TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
           }  
           if(trends[i]== 1 && (ForexStation1Up[i]  ==EMPTY_VALUE || ForexStation2Up[i]  ==EMPTY_VALUE || ForexStation3Up[i]  ==EMPTY_VALUE || ForexStation4Up[i]  ==EMPTY_VALUE || ForexStation5Up[i]  ==EMPTY_VALUE)) trends[i] = 0;
           if(trends[i]==-1 && (ForexStation1Down[i]==EMPTY_VALUE || ForexStation2Down[i]==EMPTY_VALUE || ForexStation3Down[i]==EMPTY_VALUE || ForexStation4Down[i]==EMPTY_VALUE || ForexStation5Down[i]==EMPTY_VALUE)) trends[i] = 0;
         }  //      if (alertsHowManyTimeFrameAligned == 4)
     else 
     
     
     if (DrawArrowsWhenTimeFrameAligned == 4)
        {
         if(trends[i]!=1 && ForexStation1Up[i]!=EMPTY_VALUE && ForexStation2Up[i]!=EMPTY_VALUE && ForexStation3Up[i]!=EMPTY_VALUE && ForexStation4Up[i]!=EMPTY_VALUE) 
         {
           trends[i] = 1;
           if (DisplayArrows) arrows_wind(i,"Up",ArrowGap ,UpArrowWingDingsFontCode,UpArrowColor,ArrowWidth,false);   
           }else{
           ObjectDelete(UniqueID+"Up"+TimeToStr(Time[i]));
         } 
         if(trends[i]!=-1 && ForexStation1Down[i]!=EMPTY_VALUE && ForexStation2Down[i]!=EMPTY_VALUE && ForexStation3Down[i]!=EMPTY_VALUE && ForexStation4Down[i]!=EMPTY_VALUE) 
         {
           trends[i] =-1;
           if (DisplayArrows) arrows_wind(i,"Dn",ArrowGap ,DownArrowWingDingsFontCode,DownArrowColor,ArrowWidth,true);
           }else{
           ObjectDelete(UniqueID + "Dn" + TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
           }  
           if(trends[i]== 1 && (ForexStation1Up[i]  ==EMPTY_VALUE || ForexStation2Up[i]  ==EMPTY_VALUE || ForexStation3Up[i]  ==EMPTY_VALUE || ForexStation4Up[i]  ==EMPTY_VALUE)) trends[i] = 0;
           if(trends[i]==-1 && (ForexStation1Down[i]==EMPTY_VALUE || ForexStation2Down[i]==EMPTY_VALUE || ForexStation3Down[i]==EMPTY_VALUE || ForexStation4Down[i]==EMPTY_VALUE)) trends[i] = 0;
         }  //      if (alertsHowManyTimeFrameAligned == 4)
     else 
     if (DrawArrowsWhenTimeFrameAligned == 3)
        {
         if(trends[i]!=1 && ForexStation1Up[i]!=EMPTY_VALUE && ForexStation2Up[i]!=EMPTY_VALUE && ForexStation3Up[i]!=EMPTY_VALUE) 
         {
           trends[i] = 1;
           if (DisplayArrows) arrows_wind(i,"Up",ArrowGap ,UpArrowWingDingsFontCode,UpArrowColor,ArrowWidth,false);   
           }else{
           ObjectDelete(UniqueID+"Up"+TimeToStr(Time[i]));
         } 
         if(trends[i]!=-1 && ForexStation1Down[i]!=EMPTY_VALUE && ForexStation2Down[i]!=EMPTY_VALUE && ForexStation3Down[i]!=EMPTY_VALUE) 
         {
           trends[i] =-1;
           if (DisplayArrows) arrows_wind(i,"Dn",ArrowGap ,DownArrowWingDingsFontCode,DownArrowColor,ArrowWidth,true);
           }else{
           ObjectDelete(UniqueID + "Dn" + TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
           }  
           if(trends[i]== 1 && (ForexStation1Up[i]  ==EMPTY_VALUE || ForexStation2Up[i]  ==EMPTY_VALUE || ForexStation3Up[i]  ==EMPTY_VALUE )) trends[i] = 0;
           if(trends[i]==-1 && (ForexStation1Down[i]==EMPTY_VALUE || ForexStation2Down[i]==EMPTY_VALUE || ForexStation3Down[i]==EMPTY_VALUE )) trends[i] = 0;
         } //      else if (alertsHowManyTimeFrameAligned == 3)
     else 
     if (DrawArrowsWhenTimeFrameAligned == 2)
        {
         if(trends[i]!=1 && ForexStation1Up[i]!=EMPTY_VALUE && ForexStation2Up[i]!=EMPTY_VALUE) 
         {
           trends[i] = 1;
           if (DisplayArrows) arrows_wind(i,"Up",ArrowGap ,UpArrowWingDingsFontCode,UpArrowColor,ArrowWidth,false);   
           }else{
           ObjectDelete(UniqueID+"Up"+TimeToStr(Time[i]));
         } 
         if(trends[i]!=-1 && ForexStation1Down[i]!=EMPTY_VALUE && ForexStation2Down[i]!=EMPTY_VALUE) 
         {
           trends[i] =-1;
           if (DisplayArrows) arrows_wind(i,"Dn",ArrowGap ,DownArrowWingDingsFontCode,DownArrowColor,ArrowWidth,true);
           }else{
           ObjectDelete(UniqueID + "Dn" + TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
           }  
           if(trends[i]== 1 && (ForexStation1Up[i]  ==EMPTY_VALUE || ForexStation2Up[i]  ==EMPTY_VALUE )) trends[i] = 0;
           if(trends[i]==-1 && (ForexStation1Down[i]==EMPTY_VALUE || ForexStation2Down[i]==EMPTY_VALUE )) trends[i] = 0;
         } //      else if (alertsHowManyTimeFrameAligned == 2)
     
   }   
   manageAlerts();
   return(0);
}
//+------------------------------------------------------------------+
void arrows_wind(int k, string N,int ots,int Code,color clr, int ArrowSize,bool up)                 
{           
   string objName = UniqueID+N+TimeToStr(Time[k]);
   double gap = ots*Point;
   
   ObjectCreate(objName, OBJ_ARROW,0,Time[k],0);
   ObjectSet   (objName, OBJPROP_COLOR, clr);  
   ObjectSet   (objName, OBJPROP_ARROWCODE,Code);
   ObjectSet   (objName, OBJPROP_WIDTH,ArrowSize);  
  if (up)
    {
      ObjectSet(objName, OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      ObjectSet(objName,OBJPROP_PRICE1,High[k]+gap);
    }else{  
      ObjectSet(objName, OBJPROP_ANCHOR,ANCHOR_TOP);
      ObjectSet(objName,OBJPROP_PRICE1,Low[k]-gap);
    }
}
//-------------------------------------------------------------------

/*
void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = Bars-1;
      if (trend[whichBar][_up] >= alertsHowManyTimeFrameAligned || trend[whichBar][_dn] >= alertsHowManyTimeFrameAligned)
      {
         if (trend[whichBar][_up] >= alertsHowManyTimeFrameAligned) doAlert("up"  ,trend[whichBar][_up]);
         if (trend[whichBar][_dn] >= alertsHowManyTimeFrameAligned) doAlert("down",trend[whichBar][_dn]);
      }
   }
}
*/




void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = Bars-1;
      int LastwhichBar = whichBar -1;
      if  ((TrendContinousAlertOn) && (trend[whichBar][_up] >= alertsHowManyTimeFrameAligned || trend[whichBar][_dn] >= alertsHowManyTimeFrameAligned) ) //new mod, keep showing
      {
         if (trend[whichBar][_up] >= alertsHowManyTimeFrameAligned) {
            Last4Down = false;
            Last3Down = false;   
            Last2Down = false; 
            LastDirection = "up";
            doAlertEnter("up"  ,trend[whichBar][_up]);
         }   
         if (trend[whichBar][_dn] >= alertsHowManyTimeFrameAligned) {
            Last4Up = false;
            Last3Up = false;
            Last2Up = false;
            LastDirection = "down";  
            doAlertEnter("down",trend[whichBar][_dn]);
         }
      }
  
  
  
       if (!(TrendContinousAlertOn) && (trend[whichBar][_up] >= alertsHowManyTimeFrameAligned || trend[whichBar][_dn] >= alertsHowManyTimeFrameAligned)) //show only when there was a small reverse
      {

         if ((trend[whichBar][_up] >= alertsHowManyTimeFrameAligned)&& (LastEnterUp < trend[whichBar][_up]))  {
            LastEnterUp = trend[whichBar][_up];
            LastEnterDown = 0;
            Last4Down = false;
            Last3Down = false;   
            Last2Down = false;
            LastDirection = "up";                                      
            doAlertEnter("up"  ,trend[whichBar][_up]);
         }   
         
         if ((trend[whichBar][_dn] >= alertsHowManyTimeFrameAligned)&& (LastEnterDown < trend[whichBar][_dn]))  {
            LastEnterDown = trend[whichBar][_dn];
            LastEnterUp = 0;
            Last4Up = false;
            Last3Up = false;
            Last2Up = false;
            LastDirection = "down";                         
            doAlertEnter("down",trend[whichBar][_dn]);
         }
      }
  
  
      
 if ((ReversalAlertOn) && !(TrendContinousAlertOn)) {     
      
      if ((UpLevel2) && (LastEnterDown > 0) && !(Last2Up) ) {
           Last2Up = true;
           doAlertExit("up",trend[whichBar][_up], 2);
        //   Alert (Symbol() + " Level 2 Up");
        //   SendNotification (Symbol()+" Level 2 Up");
      }
      
      if ((DownLevel2) && (LastEnterUp > 0) && !(Last2Down) ) {
           Last2Down = true;
           doAlertExit("down",trend[whichBar][_dn], 2);           
        //   Alert (Symbol() + " Level 2 Down");
        //   SendNotification (Symbol()+" Level 2 Down");
      }      
      
      if ((UpLevel3) && (LastEnterDown > 0) && !(Last3Up) ) {
           Last3Up = true;
           doAlertExit("up",trend[whichBar][_up], 3);           
        //   Alert (Symbol() + " Level 3 Up");
        //   SendNotification (Symbol()+" Level 3 Up");
      }
      
      if ((DownLevel2) && (LastEnterUp > 0) && !(Last3Down) ) {
           Last3Down = true;
            doAlertExit("down",trend[whichBar][_dn], 3);           
        //   Alert (Symbol() + " Level 3 Down");
        //   SendNotification (Symbol()+" Level 3 Down");
      }       


      if ((UpLevel4) && (LastEnterDown > 0) && !(Last4Up) ) {
           Last4Up = true;
            doAlertExit("up",trend[whichBar][_up], 4);            
        //   Alert (Symbol() + " Level 4 Up");
        //   SendNotification (Symbol()+" Level 4 Up");
      }
      
      if ((DownLevel4) && (LastEnterUp > 0) && !(Last4Down) ) {
           Last4Down = true;
            doAlertExit("down",trend[whichBar][_dn],4);           
        //   Alert (Symbol() + " Level 4 Down");
        //   SendNotification (Symbol()+" Level 4 Down");
      }  
    }// Reversal
  

      
 if ((ReversalAlertOn) && (TrendContinousAlertOn)) {     
      
      if ((UpLevel2) && !(Last2Up) ) {
           Last2Up = true;
           doAlertExit("up",trend[whichBar][_up], 2);
        //   Alert (Symbol() + " Level 2 Up");
        //   SendNotification (Symbol()+" Level 2 Up");
      }
      
      if ((DownLevel2)  && !(Last2Down) ) {
           Last2Down = true;
           doAlertExit("down",trend[whichBar][_dn], 2);           
        //   Alert (Symbol() + " Level 2 Down");
        //   SendNotification (Symbol()+" Level 2 Down");
      }      
      
      if ((UpLevel3)  && !(Last3Up) ) {
           Last3Up = true;
           doAlertExit("up",trend[whichBar][_up], 3);           
        //   Alert (Symbol() + " Level 3 Up");
        //   SendNotification (Symbol()+" Level 3 Up");
      }
      
      if ((DownLevel2)  && !(Last3Down) ) {
           Last3Down = true;
            doAlertExit("down",trend[whichBar][_dn], 3);           
        //   Alert (Symbol() + " Level 3 Down");
        //   SendNotification (Symbol()+" Level 3 Down");
      }       


      if ((UpLevel4)  && !(Last4Up) ) {
           Last4Up = true;
            doAlertExit("up",trend[whichBar][_up], 4);            
        //   Alert (Symbol() + " Level 4 Up");
        //   SendNotification (Symbol()+" Level 4 Up");
      }
      
      if ((DownLevel4) && !(Last4Down) ) {
           Last4Down = true;
            doAlertExit("down",trend[whichBar][_dn],4);           
        //   Alert (Symbol() + " Level 4 Down");
        //   SendNotification (Symbol()+" Level 4 Down");
      }  
    }// Reversal  
  
  
  
   }// if alertOn
}
//-------------------------------------------------------------------
void doAlertEnter(string doWhat, int howMany)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message; 
   string BuyorSell;
   int signalstrength;
   
   if (previousAlert != doWhat || previousTime != Time[0]) {
       previousAlert  = doWhat;
       previousTime   = Time[0];
       if (((LastDirection == "up") && (doWhat == "down")) ||  ((LastDirection == "down") && (doWhat == "up"))){LastDirection=""; BuyorSell = " 🌞"; } else {BuyorSell = "";}
       if (doWhat == "up") {BuyorSell="🍏🍏⏫BUY"; signalstrength=Upsignalstrength;} else {BuyorSell="🍎🍎⏬SELL"; signalstrength=Downsignalstrength;};
       signalstrength = MathRound(100*signalstrength/63);
       
/*       
 message =  BuyorSell+" "+Symbol() +" @ "+Close[0]+"\n"+"\n"
            +"Strength: "+candles+" ("+howMany+"/"+ArraySize(timeFrames)+" "+signalstrength+")"+"\n"
            +"Period: "+ Period()+"\n"
            +"Sensitivity: "+ Sensitive+"\n"            
            +"ProductID: "+ProductID+"\n"
            +"UniqueID: "+UniqueID ;   
 */

message =  "Enter: "+BuyorSell+" "+Symbol() +" @ "+Close[0]+"\n"+"\n"
            +"ServerTime: "+TimeToStr(TimeCurrent(),TIME_SECONDS);


 if ((timezone >= -12)&&(timezone <= 14))  message += " (GMT:"+ timezone +")"+"\n"; else message += "\n";
            
 message +=  "Strength: "+candles+" ("+howMany+"/"+ArraySize(timeFrames)+")"+"\n"
            +"Strength (%): "+signalstrength+"\n"
            +"Period: "+Period()+"M"+"\n";         

if (ATROn) {message += "Range: "+ ATR_Count(); }   
if (ADIOn) {message += "R.I.: "+ ADI_Count(); }           
            
 message += "Sensitivity: "+ Sensitive+"\n"              
      //    +"ProductID: "+ProductID+"\n"
            +"UniqueID: "+UniqueID+"\n"
            +"Mode: "+TrendContinousAlertOn+", "+ReversalAlertOn;  

          //- D'1970.1.1 00:3';
          
          if ((TimeLocal() - now > timeoffset )) {          
             if (alertsTelegram) SendTelegramChannel(message); 
             if (alertsMessage) Alert(message);  
             if (alertsEmail)   SendMail(Symbol()+" X",message);
             if (alertsNotify)  SendNotification(message);
             if (alertsSound)   PlaySound("alert2.wav");
             
     //     Alert ("YCT" + TimeLocal());
     //     Alert ("YN" + now);
     //     datetime x = TimeLocal() - now;
     //     Alert ("YTx" + x);
     //     Alert ("YTZ" + timezone);
  
             
             
             
          }
          
       //   else {
       //   Alert ("XCT" + TimeLocal());
       //   Alert ("XN" + now);
       //    datetime x = TimeLocal() - now;
       //   Alert ("xTx" + x);
       //    Alert ("XTZ" + timezone);
      
     //     }
          
          
          
          
          
   }   
          
   
}
//====================================================

void doAlertExit(string doWhat, int howMany, int Level)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message; 
   string BuyorSell;
   int signalstrength;
   
   if (previousAlert != doWhat || previousTime != Time[0]) {
       previousAlert  = doWhat;
       previousTime   = Time[0];
       if (doWhat == "up") {BuyorSell="🍏↗️Turning Bullish"; signalstrength=Upsignalstrength;} else {BuyorSell="🍎↘️Turning Bearish"; signalstrength=Downsignalstrength;
     //  if (doWhat == "up") {BuyorSell="🍏↗️Turning Bullish"; signalstrength=Upsignalstrength;} else {BuyorSell="🍎↘️Turning Bearish"; signalstrength=Downsignalstr;ength       
       
       
       }
       signalstrength = MathRound(100*signalstrength/63);
       
/*
 message =  BuyorSell+" "+Symbol() +" @ "+Close[0]+"\n"+"\n"
            +"Level: "+Level+"\n" 
            +"ServerTime: "+TimeToStr(TimeCurrent(),TIME_SECONDS)+"\n"
            +"Timeframe: "+candles+" ("+howMany+"/"+ArraySize(timeFrames)+")"+"\n"
            +"Strength: "+signalstrength+"%"+"\n"         
            +"Period: "+Period()+"M"+"\n"
            +"Sensitivity: "+ Sensitive+"\n"            
            +"ProductID: "+ProductID+"\n"
            +"UniqueID: "+UniqueID ;    
*/

 message =  "Exit: "+BuyorSell+" "+Symbol() +" Level "+Level+"\n"+"\n"
            +"Price: "+Close[0]+"\n" 
            +"ServerTime: "+TimeToStr(TimeCurrent(),TIME_SECONDS);
            
 if ((timezone >= -12)&&(timezone <= 14))  message += " (GMT:"+ timezone +")"+"\n"; else message += "\n";
            
 message +=  "Strength: "+candles+" ("+howMany+"/"+ArraySize(timeFrames)+")"+"\n"
            +"Strength (%): "+signalstrength+"\n"         
            +"Period: "+Period()+"M"+"\n";
//if (ATROn) {message += "Range: "+ ATR_Count(); } 
//if (ADIOn) {message += "R.I.: "+ ADI_Count(); }             
            
 message += "Sensitivity: "+ Sensitive+"\n"            
      //    +"ProductID: "+ProductID+"\n"
            +"UniqueID: "+UniqueID+"\n"
            +"Mode: "+TrendContinousAlertOn+", "+ReversalAlertOn;    
 
          if ((TimeLocal() - now > timeoffset )) {          
             if (alertsTelegram) SendTelegramChannel(message); 
             if (alertsMessage) Alert(message);  
             if (alertsEmail)   SendMail(Symbol()+" X",message);
             if (alertsNotify)  SendNotification(message);
             if (alertsSound)   PlaySound("alert2.wav");
             
       //   Alert ("YCT" + TimeLocal());
       //   Alert ("YN" + now);
       //    datetime x = TimeLocal() - now;
       //   Alert ("YTx" + x);
       //    Alert ("YTZ" + timezone);
      
             
          }
         
         // else {
          
        //  Alert ("XCT" + TimeLocal());
         //           Alert ("xN" + now);
         //            datetime x = TimeLocal() - now;
         // Alert ("xTx" + x);
         //            Alert ("XTZ" + timezone);
      
     //     }

          
          
          
     }     
          
      
}


//-------------------------------------------------------------------


string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

int toInt(double value) { return(value); }


int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   int max = ArraySize(iTfTable)-1, add=0;
   int nxt = (StringFind(tfs,"NEXT1")>-1); if (nxt>0) { tfs = ""+Period(); add=1; }
       nxt = (StringFind(tfs,"NEXT2")>-1); if (nxt>0) { tfs = ""+Period(); add=2; }
       nxt = (StringFind(tfs,"NEXT3")>-1); if (nxt>0) { tfs = ""+Period(); add=3; }
       nxt = (StringFind(tfs,"NEXT4")>-1); if (nxt>0) { tfs = ""+Period(); add=4; }
       nxt = (StringFind(tfs,"NEXT5")>-1); if (nxt>0) { tfs = ""+Period(); add=5; }
       nxt = (StringFind(tfs,"NEXT6")>-1); if (nxt>0) { tfs = ""+Period(); add=6; }
       nxt = (StringFind(tfs,"NEXT7")>-1); if (nxt>0) { tfs = ""+Period(); add=7; }
    
         
      for (int i=max; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[toInt(MathMin(max,i+add))],Period()));
                                                      return(Period());
}
//-------------------------------------------------------------------
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
//-------------------------------------------------------------------
string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}
//-------------------------------------------------------------------


void SendTelegramChannel1(string message)
  {
  
      //   bot.Token(BotToken);
      //   message="33333333";
   
      //   long ChatID1=(long)StringToInteger(ChatID);               
      //   int res=bot.SendMessage(ChatID1, message,NULL,false,false);
      //   if(res!=0)
      //      Alert("Error: ",GetErrorDescription(res));
  
  
  }
  
//-------------------------------------------------------------------    
  
  void SendTelegramChannel(string message)
  {
  
         message = EncodeURL(message);
         string base_url="https://api.telegram.org";
         string url=base_url+"/bot"+BotToken+"/sendMessage?chat_id="+ChatID+"&text="+message;
   
         string myIP = httpGET(url);
  
  
  }
  
  
  
    void SendTelegramChannel2(string message)
  {
  
         message = EncodeURL(message);
         Alert (message);
  
  
  }
  
  
  
//-------------------------------------------------------------------  
  
  string EncodeURL(string str)
{
    char   array[];
    string result = "";

    const int len = StringToCharArray(str, array, 0, -1, CP_UTF8) - 1;

    for (int i = 0; i < len; i++)
    {
        const unsigned char c = array[i];

        if (((c >= '0') && (c <= '9')) ||
            ((c >= 'A') && (c <= 'Z')) ||
            ((c >= 'a') && (c <= 'z')) ||
            (c == '-') ||
            (c == '_') ||
            (c == '.') ||
            (c == '~'))
        {
            result += CharToString(c);
        }
        else if (c == ' ')
        {
            result += CharToString('+');
        }
        else
        {
            result += StringFormat("%%%02X", c);
        }
    }

    return result;
}

//-------------------------------------------------------------------

#import "kernel32.dll"
  int GetSystemTime(int& buf[]);
#import
//+------------------------------------------------------------------+
//|                                 Function  :      void SetObject()|
//|                                 Copyright © 2010, XrustSolution. |
//|                                           mail: xrustx@gmail.com |
//+------------------------------------------------------------------+
int GetTimeZone(){
        int in_ho = TimeHour(TimeCurrent());
        int st[4];
        GetSystemTime(st);
        int GMT = st[2] & 0xFFFF;
        int res = in_ho - GMT;
        if(res<0){in_ho+=24;}
        return(in_ho-GMT);  
}

//-------------------------------------------------------------------
string ATR_Count () {


// string ATR_msg = iATR(NULL,0,ATRPeriod,0);  
 
 //  double ATRPoints=iATR(NULL,0,InpATRperiod,0);  
 //int stringToTimeFrame(string tfs)

/*
double  iATR(
   string       symbol,     // symbol
   int          timeframe,  // timeframe
   int          period,     // averaging period
   int          shift       // shift
   );
*/

 string ATR_msg = MathRound(iATR(NULL, stringToTimeFrame(TimeFrame1), ATRPeriod,0)/Point())+"📏";  
        ATR_msg += ", " + MathRound(iATR(NULL, stringToTimeFrame(TimeFrame2), ATRPeriod,0)/Point());   
        ATR_msg += ", " + MathRound(iATR(NULL, stringToTimeFrame(TimeFrame3), ATRPeriod,0)/Point());   
        ATR_msg += ", " + MathRound(iATR(NULL, stringToTimeFrame(TimeFrame4), ATRPeriod,0)/Point());   
        ATR_msg += ", " + MathRound(iATR(NULL, stringToTimeFrame(TimeFrame5), ATRPeriod,0)/Point());   
        ATR_msg += ", " + MathRound(iATR(NULL, stringToTimeFrame(TimeFrame6), ATRPeriod,0)/Point())+"\n";
        
 return (ATR_msg);          

}

//-------------------------------------------------------------------


string ADI_Count () {

//iADX(NULL,0,14,PRICE_CLOSE,MODE_MAIN,0);

 string ATR_msg = MathRound(iADX(NULL, stringToTimeFrame(TimeFrame1), ATRPeriod,PRICE_CLOSE,MODE_MAIN,0));  
        ATR_msg += ", " + MathRound(iADX(NULL, stringToTimeFrame(TimeFrame2), ADIPeriod,PRICE_CLOSE,MODE_MAIN,0));   
        ATR_msg += ", " + MathRound(iADX(NULL, stringToTimeFrame(TimeFrame3), ADIPeriod,PRICE_CLOSE,MODE_MAIN,0));   
        ATR_msg += ", " + MathRound(iADX(NULL, stringToTimeFrame(TimeFrame4), ADIPeriod,PRICE_CLOSE,MODE_MAIN,0));   
        ATR_msg += ", " + MathRound(iADX(NULL, stringToTimeFrame(TimeFrame5), ADIPeriod,PRICE_CLOSE,MODE_MAIN,0));   
        ATR_msg += ", " + MathRound(iADX(NULL, stringToTimeFrame(TimeFrame6), ADIPeriod,PRICE_CLOSE,MODE_MAIN,0))+"\n";
        
 return (ATR_msg);          

}
