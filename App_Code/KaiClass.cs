using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace KaiClass
{
    public class ETagBaseData
    {
        public string DEVICEID;
        public string RECEIVEDATE;
        public string LANEID;
        public string PLATEID;
        public string CarType;
    }
    public class gogoTime
    {
        public int Avg;
        public int Max;
        public int Min;
        public string Hour;
    }

    public class weekDayNum
    {
        public int DayOfWeek;
        public string Ndate;
        public int Hour;
        public int AllNums = 0;
        public int Nums = 0;
        public int BNums = 0;
        public string DEVICEID;
        public string Type;
    }

    public class ETagTimeFlowOneTemp
    {
        public int Hour;
        public string Date;
        public int Nums;
    }




    public class eTagTimeFlowWeek
    {
        public string Hour;
        public int OneNum = 0;
        public int TwoNum = 0;
        public int BOneNum = 0;
        public int BTwoNum = 0;
        public int SOneNum = 0;
        public int STwoNum = 0;
    }

    public class eTagTimeFlowTwo
    {
        public int Hour;
        public int Nums;
        public string DEVICEID;
    }

    public class ETagDataTodayNum
    {
        public int OneComeNum = 0;
        public int OneLeaveNum = 0;
        public int OneStopNum = 0;
        public int OneHComeNum = 0;
        public int OneHLeaveNum = 0;
        public int OneHStopNum = 0;
    }

    public class HomeTemp1
    {
        public int Hour;
        public int ComeNums;
        public int LeaveNums;
        public int StopNums;
    }

    public class HomeChart1
    {
        public string Hour;
        public int ComeNums;
        public int LeaveNums;
        public int StopNums;
    }


    public class TopETagNum
    {
        public string DeviceID;
        public int Nums;
        public string RoadName;
    }
    public class eTagAllFlow
    {
        public int Hour;
        public int Minute;
        public int Nums;
    }

    public class TimeFlowClass
    {
        public string Hour;
        public string Minute;
        public string LeftTitle;
        public int ComeAllNums;
        public int ComeBNums;
        public int ComeSNums;
        public int LeaveAllNums;
        public int LeaveBNums;
        public int LeaveSNums;
        public TimeFlowClass(string LeftTitle)
        {
            this.LeftTitle = LeftTitle;
            LeaveAllNums = 0;
            LeaveBNums = 0;
            LeaveSNums = 0;
            ComeAllNums = 0;
            ComeBNums = 0;
            ComeSNums = 0;
        }
        public TimeFlowClass()
        {
            LeaveAllNums = 0;
            LeaveBNums = 0;
            LeaveSNums = 0;
            ComeAllNums = 0;
            ComeBNums = 0;
            ComeSNums = 0;
        }
    }

    public class TimeFlowTableGroup:List<TimeFlowTable>
    {
      
    }

    public class TimeFlowTable : List<TimeFlowClass>
    {
        public TimeFlowTable(string type)
        {
            if (type.Equals("1"))
            {
                for (int i = 0; i < 24; i++)
                {
                    TimeFlowClass temp = new TimeFlowClass();
                    if (i.ToString().Length == 1)
                    {
                        if (i == 9)
                        {
                            temp.LeftTitle = "0" + i + ":00 - " + (i + 1) + ":00";
                        }
                        else
                        {
                            temp.LeftTitle = "0" + i + ":00 - 0" + (i + 1) + ":00";
                        }
                    }
                    else
                    {
                        temp.LeftTitle = i + ":00 - " + (i + 1) + ":00";
                    }
                    this.Add(temp);
                }
            }
            else if (type.Equals("2"))
            {
                for (int i = 0; i < 24; i++)
                {
                    for (int j = 0; j < 4; j++)
                    {
                        TimeFlowClass temp = new TimeFlowClass();
                        if (i.ToString().Length == 1)
                        {
                            if (i == 9)
                            {

                                if (j == 0)
                                {

                                    temp.LeftTitle = "0" + i + ":00 - " + i + ":" + (j + 1) * 15;
                                }
                                else if (j == 3)
                                {
                                    temp.LeftTitle = "0" + i + ":" + j * 15 + " - " + (i + 1) + ":00";
                                }
                                else
                                {
                                    temp.LeftTitle = "0" + i + ":" + j * 15 + " - " + i + ":" + (j + 1) * 15;
                                }
                            }
                            else
                            {
                                if (j == 0)
                                {
                                    temp.LeftTitle = "0" + i + ":00 - 0" + i + ":" + (j + 1) * 15;
                                }
                                else if (j == 3)
                                {
                                    temp.LeftTitle = "0" + i + ":" + j * 15 + " - 0" + (i + 1) + ":00";
                                }
                                else
                                {
                                    temp.LeftTitle = "0" + i + ":" + j * 15 + " - 0" + i + ":" + (j + 1) * 15;
                                }
                            }
                        }
                        else
                        {
                            if (j == 0)
                            {
                                temp.LeftTitle = i + ":00 - " + i + ":" + (j + 1) * 15;
                            }
                            else if (j == 3)
                            {
                                temp.LeftTitle = i + ":" + j * 15 + " - " + (i + 1) + ":00";
                            }
                            else
                            {
                                temp.LeftTitle = i + ":" + j * 15 + " - " + i + ":" + (j + 1) * 15;
                            }

                        }
                        this.Add(temp);
                    }
                }
            }
            this.Add(new TimeFlowClass("晨峰"));
            this.Add(new TimeFlowClass("昏峰"));
            this.Add(new TimeFlowClass("離峰"));
            this.Add(new TimeFlowClass("全日"));
        }

    }
}
