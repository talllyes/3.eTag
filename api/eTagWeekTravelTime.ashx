<%@ WebHandler Language="C#" Class="eTagWeekTravelTime" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;
using KaiValid;
using KaiClass;
using NPOI;
using NPOI.HSSF.UserModel;
using NPOI.XSSF.UserModel;
using NPOI.SS.UserModel;
using System.IO;
using System.Threading.Tasks;

public class eTagWeekTravelTime : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        DataClasses3DataContext DB = new DataClasses3DataContext();
        DataClassesDataContext DB2 = new DataClassesDataContext();
        string type = context.Items["type"].ToString();
        string str = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
        if (type.Equals("取得eTag基本資料"))
        {
            var result = from a in DB.ETAG_INFO
                         orderby a.id
                         select new
                         {
                             a.id,
                             a.px,
                             a.py,
                             title = a.roadname,
                             choose = false
                         };
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("處理週內日分時旅行時間資料"))
        {
            dynamic json = JValue.Parse(str);
            string tempDate = json.startDate;
            string tempDate2 = json.endDate;
            string startDate = DateProcess.民國年轉西元年回傳字串格式(tempDate);
            string endDate = DateProcess.民國年轉西元年回傳字串格式(tempDate2, 1);
            DateTime startDateD = DateProcess.民國年轉西元年回傳日期格式(tempDate);
            DateTime endDateD = DateProcess.民國年轉西元年回傳日期格式(tempDate2, 1);
            DateTime dendDateD = DateProcess.民國年轉西元年回傳日期格式(tempDate2);
            DateTime pstart = DateTime.Now;
            string name = "";
            Report insert;
            int result = (from a in DB2.Report
                          where a.Context == null && a.Type == 4
                          select a).Count();
            if (result < 3)
            {
                if (json.roadData != null)
                {
                    foreach (var tempSelectETag in json.roadData)
                    {
                        if ((bool)tempSelectETag.choose)
                        {
                            name = name + tempSelectETag.roadName;
                        }
                    }
                    insert = new Report
                    {
                        ReportStartDate = startDateD,
                        ReportEndDate = dendDateD,
                        CreateDate = pstart,
                        Type = 4,
                        Name = name
                    };
                    DB2.Report.InsertOnSubmit(insert);
                    DB2.SubmitChanges();

                    context.Response.ContentType = "text/plain";
                    context.Response.Write(insert.ReportID);
                }
            }
            else
            {
                context.Response.ContentType = "text/plain";
                context.Response.Write("no");
            }
        }
        else if (type.Equals("週內日分時旅行時間資料"))
        {
            Task.Run(() => 週內日分時旅行時間資料(DB, DB2, context, str));
        }
        else
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("什麼都沒有唷");
        }
    }

    public void 儲存報表數量(eTag分時旅行報表Row 報表, int 數量, int type)
    {
        if (type == 1)
        {
            報表.AvgSecond = 報表.AvgSecond + 數量;
        }
        else if (type == 2)
        {
            報表.Max = 報表.Max + 數量;
        }
        else if (type == 3)
        {
            報表.Min = 報表.Min + 數量;
        }
        else if (type == 4)
        {
            報表.CarNum = 報表.CarNum + 數量;
        }
    }

    public class eTag基本資料
    {
        public string ID;
        public string RoadName;
        public string date;
    }

    public class eTag週內日分時旅行時間
    {
        public string 日期;
        public int 平均;
        public int 最大;
        public int 最小;
        public int 週內日;
        public int 小時;
        public int 數量;
    }

    public class eTag分時旅行報表Row
    {
        public string Hour;
        public dynamic AvgSecond;
        public dynamic AvgSpeedHour;
        public dynamic CarNum;
        public dynamic Max;
        public dynamic Min;
        public dynamic MaxHour;
        public dynamic MinHour;

        public eTag分時旅行報表Row(string str)
        {
            Hour = str;
            AvgSecond = 0;
            AvgSpeedHour = 0;
            CarNum = 0;
            Max = 0;
            Min = 0;
            MaxHour = 0;
            MinHour = 0;
        }
        public eTag分時旅行報表Row()
        {
            AvgSecond = 0;
            AvgSpeedHour = 0;
            CarNum = 0;
            Max = 0;
            Min = 0;
            MaxHour = 0;
            MinHour = 0;
        }
    }

    public static List<eTag分時旅行報表Row> eTag分時旅行報表Create()
    {
        List<eTag分時旅行報表Row> 報表 = new List<eTag分時旅行報表Row>();
        for (int i = 0; i < 24; i++)
        {
            eTag分時旅行報表Row temp = new eTag分時旅行報表Row();
            if (i.ToString().Length == 1)
            {
                if (i == 9)
                {
                    temp.Hour = "0" + i + ":00 - " + (i + 1) + ":00";
                }
                else
                {
                    temp.Hour = "0" + i + ":00 - 0" + (i + 1) + ":00";
                }
            }
            else
            {
                temp.Hour = i + ":00 - " + (i + 1) + ":00";
            }
            報表.Add(temp);
        }
        報表.Add(new eTag分時旅行報表Row("晨峰"));
        報表.Add(new eTag分時旅行報表Row("昏峰"));
        報表.Add(new eTag分時旅行報表Row("離峰"));
        報表.Add(new eTag分時旅行報表Row("全日"));
        return 報表;
    }


    public class eTag分時旅行報表
    {
        public List<eTag分時旅行報表Row> 星期日;
        public List<eTag分時旅行報表Row> 星期一;
        public List<eTag分時旅行報表Row> 星期二;
        public List<eTag分時旅行報表Row> 星期三;
        public List<eTag分時旅行報表Row> 星期四;
        public List<eTag分時旅行報表Row> 星期五;
        public List<eTag分時旅行報表Row> 星期六;
        public eTag分時旅行報表()
        {
            星期日 = eTag分時旅行報表Create();
            星期一 = eTag分時旅行報表Create();
            星期二 = eTag分時旅行報表Create();
            星期三 = eTag分時旅行報表Create();
            星期四 = eTag分時旅行報表Create();
            星期五 = eTag分時旅行報表Create();
            星期六 = eTag分時旅行報表Create();
        }
    }
    public void 計算平均值(List<eTag分時旅行報表Row> 星期, int n)
    {
        int temp = 1;
        if (n != 0)
        {
            temp = n;
        }
        for (int i = 0; i < 28; i++)
        {
            星期[i].AvgSecond = 星期[i].AvgSecond / temp;
            星期[i].Max = 星期[i].Max / temp;
            星期[i].Min = 星期[i].Min / temp;
        }
    }



    public void 計算星期速率(eTag分時旅行報表 報表, int distance)
    {
        速率計算(報表.星期日, distance);
        速率計算(報表.星期一, distance);
        速率計算(報表.星期二, distance);
        速率計算(報表.星期三, distance);
        速率計算(報表.星期四, distance);
        速率計算(報表.星期五, distance);
        速率計算(報表.星期六, distance);
    }

    public void 速率計算(List<eTag分時旅行報表Row> 星期, int distance)
    {
        for (int k = 0; k < 28; k++)
        {
            星期[k].AvgSpeedHour = 時速公里計算到小數(星期[k].AvgSecond, distance, 1);
            星期[k].MaxHour = 時速公里計算到小數(星期[k].Max, distance, 1);
            星期[k].MinHour = 時速公里計算到小數(星期[k].Min, distance, 1);
            星期[k].AvgSecond = 分鐘計算到小數(星期[k].AvgSecond, 1);
            星期[k].Max = 分鐘計算到小數(星期[k].Max, 1);
            星期[k].Min = 分鐘計算到小數(星期[k].Min, 1);
        }
    }

    public void 平均計算(eTag分時旅行報表 報表)
    {
        晨峰計算(報表.星期日);
        昏峰計算(報表.星期日);
        離峰計算(報表.星期日);
        全日計算(報表.星期日);

        晨峰計算(報表.星期一);
        昏峰計算(報表.星期一);
        離峰計算(報表.星期一);
        全日計算(報表.星期一);

        晨峰計算(報表.星期二);
        昏峰計算(報表.星期二);
        離峰計算(報表.星期二);
        全日計算(報表.星期二);

        晨峰計算(報表.星期三);
        昏峰計算(報表.星期三);
        離峰計算(報表.星期三);
        全日計算(報表.星期三);

        晨峰計算(報表.星期四);
        昏峰計算(報表.星期四);
        離峰計算(報表.星期四);
        全日計算(報表.星期四);

        晨峰計算(報表.星期五);
        昏峰計算(報表.星期五);
        離峰計算(報表.星期五);
        全日計算(報表.星期五);

        晨峰計算(報表.星期六);
        昏峰計算(報表.星期六);
        離峰計算(報表.星期六);
        全日計算(報表.星期六);
    }
    public void 晨峰計算(List<eTag分時旅行報表Row> 星期)
    {
        星期[24].AvgSecond = (星期[7].AvgSecond + 星期[8].AvgSecond) / 2;
        星期[24].Min = (星期[7].Min + 星期[8].Min) / 2;
        星期[24].Max = (星期[7].Max + 星期[8].Max) / 2;
        星期[24].CarNum = 星期[7].CarNum + 星期[8].CarNum;
    }
    public void 昏峰計算(List<eTag分時旅行報表Row> 星期)
    {
        星期[25].AvgSecond = (星期[16].AvgSecond + 星期[17].AvgSecond) / 2;
        星期[25].Min = (星期[17].Min + 星期[18].Min) / 2;
        星期[25].Max = (星期[17].Max + 星期[18].Max) / 2;
        星期[25].CarNum = 星期[17].CarNum + 星期[18].CarNum;
    }

    public void 離峰計算(List<eTag分時旅行報表Row> 星期)
    {
        for (int i = 9; i < 17; i++)
        {
            星期[26].AvgSecond = 星期[26].AvgSecond + 星期[i].AvgSecond;
            星期[26].Min = 星期[26].Min + 星期[i].Min;
            星期[26].Max = 星期[26].Max + 星期[i].Max;
            星期[26].CarNum = 星期[26].CarNum + 星期[i].CarNum;
        }
        星期[26].AvgSecond = 星期[26].AvgSecond / 8;
        星期[26].Min = 星期[26].Min / 8;
        星期[26].Max = 星期[26].Max / 8;
    }

    public void 全日計算(List<eTag分時旅行報表Row> 星期)
    {
        for (int j = 0; j < 24; j++)
        {
            星期[27].AvgSecond = 星期[27].AvgSecond + 星期[j].AvgSecond;
            星期[27].Min = 星期[27].Min + 星期[j].Min;
            星期[27].Max = 星期[27].Max + 星期[j].Max;
            星期[27].CarNum = 星期[27].CarNum + 星期[j].CarNum;
        }
        星期[27].AvgSecond = 星期[27].AvgSecond / 24;
        星期[27].Min = 星期[27].Min / 24;
        星期[27].Max = 星期[27].Max / 24;
    }

    public string 時速公里計算到小數(dynamic value, int distance, int n)
    {
        double temp = value;
        string output = "0.";
        if (temp != 0)
        {
            temp = distance / temp;
            temp = (temp * 60 * 60) / 1000;
            for (int i = 0; i < n; i++)
            {
                output = output + "0";
            }
        }
        return temp.ToString(output);
    }
    public string 分鐘計算到小數(dynamic value, int n)
    {
        double temp = value;
        string output = "0.";
        temp = temp / 60;
        for (int i = 0; i < n; i++)
        {
            output = output + "0";
        }

        return temp.ToString(output);
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

    private void 週內日分時旅行時間資料(DataClasses3DataContext DB, DataClassesDataContext DB2, HttpContext context, string str)
    {
        dynamic json = JValue.Parse(str);
        string tempDate = json.startDate;
        string tempDate2 = json.endDate;
        int reportid = json.reportid;
        string startDate = DateProcess.民國年轉西元年回傳字串格式(tempDate);
        string endDate = DateProcess.民國年轉西元年回傳字串格式(tempDate2, 1);
        DateTime startDateD = DateProcess.民國年轉西元年回傳日期格式(tempDate);
        DateTime endDateD = DateProcess.民國年轉西元年回傳日期格式(tempDate2, 1);
        string name = "";
        DateTime pstart = DateTime.Now;
        Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
        if (json.roadData != null)
        {
            List<string> tempTitle = new List<string>();


            foreach (var tempSelectETag in json.roadData)
            {
                eTag分時旅行報表 報表 = new eTag分時旅行報表();
                for (int i = 0; i < 24; i++)
                {
                    string sql = @"select case when AVG(x.Second) is null then 0 else AVG(x.Second) end as 平均,
                                       case when Min(x.Second) is null then 0 else Min(x.Second) end as 最小,
                                       case when Max(x.Second) is null then 0 else Max(x.Second) end as 最大,
                                       count(*) as 數量,x.Week as 週內日,x.date as 日期
                                       from (select MIN(w.Second) as Second,w.PLATEID,w.week,w.date
                                       from (select DatePart(WeekDay,b.RECEIVEDATE) week,CONVERT(varchar(100), b.RECEIVEDATE, 112) date,
                                       DateDiff(SECOND,a.RECEIVEDATE,b.RECEIVEDATE) as Second,a.PLATEID
                                       from (SELECT *
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                                       where [RECEIVEDATE]>='" + startDate + @"'
                                       and [RECEIVEDATE]<'" + endDate + @"'
                                       and [DEVICEID]='" + tempSelectETag.startID + @"'";
                    foreach (var notDateListTemp in json.notDateList)
                    {
                        string ttTemp = DateProcess.民國年轉西元年回傳字串格式(notDateListTemp.date);
                        sql = sql + @" and CONVERT(varchar(100), RECEIVEDATE, 112)!='" + ttTemp + "'";
                    }
                    sql = sql + @") a,(SELECT *
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                                       where [RECEIVEDATE]>='" + startDate + @"'
                                       and [RECEIVEDATE]<'" + endDate + @"'
                                       and [DEVICEID]='" + tempSelectETag.endID + @"'
                                       and datepart(hh,RECEIVEDATE)=" + i;
                    foreach (var notDateListTemp in json.notDateList)
                    {
                        string ttTemp = DateProcess.民國年轉西元年回傳字串格式(notDateListTemp.date);
                        sql = sql + @" and CONVERT(varchar(100), RECEIVEDATE, 112)!='" + ttTemp + "'";
                    }
                    sql = sql + @") b 
                                         where a.PLATEID=b.PLATEID) w where w.Second>0 and
                                         w.Second<" + (tempSelectETag.Max * 60) + @" and w.Second>" + (tempSelectETag.Min * 60) + @"
                                         group by w.PLATEID,w.week,w.date				
                                         ) x group by x.week,x.date";
                    var eTag週內日分時流量 = DB.ExecuteQuery<eTag週內日分時旅行時間>(sql);
                    foreach (var temp in eTag週內日分時流量)
                    {
                        if (temp.週內日 == 1)
                        {
                            儲存報表數量(報表.星期日[i], temp.平均, 1);
                            儲存報表數量(報表.星期日[i], temp.最大, 2);
                            儲存報表數量(報表.星期日[i], temp.最小, 3);
                            儲存報表數量(報表.星期日[i], temp.數量, 4);
                        }
                        else if (temp.週內日 == 2)
                        {
                            儲存報表數量(報表.星期一[i], temp.平均, 1);
                            儲存報表數量(報表.星期一[i], temp.最大, 2);
                            儲存報表數量(報表.星期一[i], temp.最小, 3);
                            儲存報表數量(報表.星期一[i], temp.數量, 4);
                        }
                        else if (temp.週內日 == 3)
                        {
                            儲存報表數量(報表.星期二[i], temp.平均, 1);
                            儲存報表數量(報表.星期二[i], temp.最大, 2);
                            儲存報表數量(報表.星期二[i], temp.最小, 3);
                            儲存報表數量(報表.星期二[i], temp.數量, 4);
                        }
                        else if (temp.週內日 == 4)
                        {
                            儲存報表數量(報表.星期三[i], temp.平均, 1);
                            儲存報表數量(報表.星期三[i], temp.最大, 2);
                            儲存報表數量(報表.星期三[i], temp.最小, 3);
                            儲存報表數量(報表.星期三[i], temp.數量, 4);
                        }
                        else if (temp.週內日 == 5)
                        {
                            儲存報表數量(報表.星期四[i], temp.平均, 1);
                            儲存報表數量(報表.星期四[i], temp.最大, 2);
                            儲存報表數量(報表.星期四[i], temp.最小, 3);
                            儲存報表數量(報表.星期四[i], temp.數量, 4);
                        }
                        else if (temp.週內日 == 6)
                        {
                            儲存報表數量(報表.星期五[i], temp.平均, 1);
                            儲存報表數量(報表.星期五[i], temp.最大, 2);
                            儲存報表數量(報表.星期五[i], temp.最小, 3);
                            儲存報表數量(報表.星期五[i], temp.數量, 4);
                        }
                        else if (temp.週內日 == 7)
                        {
                            儲存報表數量(報表.星期六[i], temp.平均, 1);
                            儲存報表數量(報表.星期六[i], temp.最大, 2);
                            儲存報表數量(報表.星期六[i], temp.最小, 3);
                            儲存報表數量(報表.星期六[i], temp.數量, 4);
                        }
                    }
                }
                int tempDistance = tempSelectETag.distance;
                平均計算(報表);


                int SundayNum = 0;
                int MondayNum = 0;
                int TuesdayNum = 0;
                int WednesdayNum = 0;
                int ThursdayNum = 0;
                int FridayNum = 0;
                int SaturdayNum = 0;
                DateTime countDate = startDateD;
                while (countDate.Date < endDateD.Date)
                {
                    DateTime dateTemp;
                    bool flag = true;
                    foreach (var notDateListTemp in json.notDateList)
                    {
                        dateTemp = DateProcess.民國年轉西元年回傳日期格式(notDateListTemp.date);
                        if (dateTemp.Date == countDate.Date)
                        {
                            flag = false;
                        }
                    }
                    if (flag)
                    {
                        if (countDate.DayOfWeek == DayOfWeek.Monday)
                        {
                            MondayNum = MondayNum + 1;
                        }
                        else if (countDate.DayOfWeek == DayOfWeek.Tuesday)
                        {
                            TuesdayNum = TuesdayNum + 1;
                        }
                        else if (countDate.DayOfWeek == DayOfWeek.Wednesday)
                        {
                            WednesdayNum = WednesdayNum + 1;
                        }
                        else if (countDate.DayOfWeek == DayOfWeek.Thursday)
                        {
                            ThursdayNum = ThursdayNum + 1;
                        }
                        else if (countDate.DayOfWeek == DayOfWeek.Friday)
                        {
                            FridayNum = FridayNum + 1;
                        }
                        else if (countDate.DayOfWeek == DayOfWeek.Saturday)
                        {
                            SaturdayNum = SaturdayNum + 1;
                        }
                        else if (countDate.DayOfWeek == DayOfWeek.Sunday)
                        {
                            SundayNum = SundayNum + 1;
                        }
                    }
                    countDate = countDate.AddDays(1);
                }


                計算平均值(報表.星期日, SundayNum);
                計算平均值(報表.星期一, MondayNum);
                計算平均值(報表.星期二, TuesdayNum);
                計算平均值(報表.星期三, WednesdayNum);
                計算平均值(報表.星期四, ThursdayNum);
                計算平均值(報表.星期五, FridayNum);
                計算平均值(報表.星期六, SaturdayNum);

                計算星期速率(報表, tempDistance);

                string tempID = tempSelectETag.id;
                eTag基本資料 baseInfo = new eTag基本資料();
                baseInfo.date = tempDate + " ~ " + tempDate2;
                baseInfo.ID = tempSelectETag.id;
                baseInfo.RoadName = tempSelectETag.roadName;
                name = baseInfo.RoadName;
                result.Add("baseInfo", baseInfo);
                result.Add("report", 報表);
            }
            var update = (from b in DB2.Report
                          where b.ReportID == reportid
                          select b).FirstOrDefault();
            update.Context = JsonConvert.SerializeObject(result);
            update.EndDate = DateTime.Now;
            DB2.SubmitChanges();
        }
    }
}