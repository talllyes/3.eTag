<%@ WebHandler Language="C#" Class="eTagTravelTime" %>

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

public class eTagTravelTime : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        DataClasses3DataContext DB = new DataClasses3DataContext();
        DataClassesDataContext DB2 = new DataClassesDataContext();
        string type = context.Items["type"].ToString();
        string str = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
        if (type.Equals("eTag基本資料"))
        {
            var result = from a in DB.ETAG_INFO
                         orderby a.id
                         select new
                         {
                             a.id,
                             a.px,
                             a.py,
                             title = a.roadname
                         };
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("處理分時旅行時間資料"))
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
                          where a.Context == null && a.Type == 3
                          select a).Count();
            if (result < 3)
            {
                if (json.roadData != null)
                {
                    foreach (var tempSelectETag in json.roadData)
                    {
                        name = name + tempSelectETag.roadName;
                    }
                    insert = new Report
                    {
                        ReportStartDate = startDateD,
                        ReportEndDate = startDateD,
                        CreateDate = pstart,
                        Type = 3,
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
        else if (type.Equals("分時旅行時間資料"))
        {
            Task.Run(() => 分時旅行時間資料(DB, DB2, context, str));
        }
        else
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("什麼都沒有唷");
        }
    }

    public void 分時旅行時間資料(DataClasses3DataContext DB, DataClassesDataContext DB2, HttpContext context, string str)
    {
        dynamic json = JValue.Parse(str);
        string tempDate = json.startDate;
        string startDate = DateProcess.民國年轉西元年回傳字串格式(tempDate);
        string endDate = DateProcess.民國年轉西元年回傳字串格式(tempDate, 1);
        List<dynamic> result = new List<dynamic>();
        int reportid = json.reportid;
        if (json.roadData != null)
        {
            List<string> tempTitle = new List<string>();
            foreach (var tempSelectETagRoad in json.roadData)
            {
                eTag分時流量報表 報表 = new eTag分時流量報表();
                Dictionary<string, dynamic> 基本資料 = new Dictionary<string, dynamic>();
                for (int i = 0; i < 24; i++)
                {
                    string sql = @"select case when AVG(x.Second) is null then 0 else AVG(x.Second) end as Avg,
                                       case when Min(x.Second) is null then 0 else Min(x.Second) end as Min,
                                       case when Max(x.Second) is null then 0 else Max(x.Second) end as Max,'" + i + @"' Hour,
                                       count(*) as carNum
                                       from (select w.Hour,MIN(w.Second) as Second,w.PLATEID
                                       from (select datepart(hh,b.RECEIVEDATE) Hour,
                                       DateDiff(SECOND,a.RECEIVEDATE,b.RECEIVEDATE) as Second,a.PLATEID
                                       from (SELECT *
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                                       where RECEIVEDATE>='" + startDate + @"' and RECEIVEDATE<'" + endDate + @"'
                                       and [DEVICEID]='" + tempSelectETagRoad.startID + @"'
                                       ) a,(SELECT *
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                                       where RECEIVEDATE>='" + startDate + @"' and RECEIVEDATE<'" + endDate + @"'
                                       and datepart(hh,RECEIVEDATE)=" + i + @"
                                       and [DEVICEID]='" + tempSelectETagRoad.endID + @"'
                                       ) b 
                                       where a.PLATEID=b.PLATEID) w
                                       where w.Second>0 and 
                                       w.Second<" + (tempSelectETagRoad.Max * 60) + @" and w.Second>" + (tempSelectETagRoad.Min * 60) + @"
                                       group by w.PLATEID,w.Hour							
                                       ) x";
                    var eTag分時旅行時間 = DB.ExecuteQuery<eTag分時旅行時間>(sql).FirstOrDefault();
                    報表.報表[i].AvgSecond = eTag分時旅行時間.Avg;
                    報表.報表[i].Max = eTag分時旅行時間.Max;
                    報表.報表[i].Min = eTag分時旅行時間.Min;
                    報表.報表[i].CarNum = eTag分時旅行時間.CarNum;
                }

                //晨峰7-9
                報表.報表[24].AvgSecond = (報表.報表[7].AvgSecond + 報表.報表[8].AvgSecond) / 2;
                報表.報表[24].Max = (報表.報表[7].Max + 報表.報表[8].Max) / 2;
                報表.報表[24].Min = (報表.報表[7].Min + 報表.報表[8].Min) / 2;
                報表.報表[24].CarNum = (報表.報表[8].CarNum + 報表.報表[8].CarNum);
                //昏峰17-19
                報表.報表[25].AvgSecond = (報表.報表[17].AvgSecond + 報表.報表[18].AvgSecond) / 2;
                報表.報表[25].Max = (報表.報表[17].Max + 報表.報表[18].Max) / 2;
                報表.報表[25].Min = (報表.報表[17].Min + 報表.報表[18].Min) / 2;
                報表.報表[25].CarNum = (報表.報表[17].CarNum + 報表.報表[18].CarNum) / 2;
                //離峰9-17
                for (int j = 9; j < 18; j++)
                {
                    報表.報表[26].AvgSecond = 報表.報表[26].AvgSecond + 報表.報表[j].AvgSecond;
                    報表.報表[26].Max = 報表.報表[26].Max + 報表.報表[j].Max;
                    報表.報表[26].Min = 報表.報表[26].Min + 報表.報表[j].Min;
                    報表.報表[26].CarNum = 報表.報表[26].CarNum + 報表.報表[j].CarNum;
                }
                報表.報表[26].AvgSecond = 報表.報表[26].AvgSecond / 8;
                報表.報表[26].Max = 報表.報表[26].Max / 8;
                報表.報表[26].Min = 報表.報表[26].Min / 8;

                //全日                        
                for (int j = 0; j < 24; j++)
                {
                    報表.報表[27].AvgSecond = 報表.報表[27].AvgSecond + 報表.報表[j].AvgSecond;
                    報表.報表[27].Max = 報表.報表[27].Max + 報表.報表[j].Max;
                    報表.報表[27].Min = 報表.報表[27].Min + 報表.報表[j].Min;
                    報表.報表[27].CarNum = 報表.報表[27].CarNum + 報表.報表[j].CarNum;
                }
                報表.報表[27].AvgSecond = 報表.報表[27].AvgSecond / 24;
                報表.報表[27].Max = 報表.報表[27].Max / 24;
                報表.報表[27].Min = 報表.報表[27].Min / 24;

                for (int k = 0; k < 28; k++)
                {
                    int distance = tempSelectETagRoad.distance;
                    報表.報表[k].AvgSpeedHour = 時速公里計算到小數(報表.報表[k].AvgSecond, distance, 1);
                    報表.報表[k].MaxHour = 時速公里計算到小數(報表.報表[k].Max, distance, 1);
                    報表.報表[k].MinHour = 時速公里計算到小數(報表.報表[k].Min, distance, 1);
                }
                for (int k = 0; k < 28; k++)
                {
                    報表.報表[k].AvgSecond = 分鐘計算到小數(報表.報表[k].AvgSecond, 1);
                    報表.報表[k].Max = 分鐘計算到小數(報表.報表[k].Max, 1);
                    報表.報表[k].Min = 分鐘計算到小數(報表.報表[k].Min, 1);
                }

                eTag基本資料 baseInfo = new eTag基本資料();
                baseInfo.Date = tempDate;
                baseInfo.StartID = tempSelectETagRoad.startID;
                baseInfo.EndID = tempSelectETagRoad.endID;
                baseInfo.RoadName = tempSelectETagRoad.roadName;
                string excelsql = @"select max(gg.ins) 進來時間,gg.outs 離開時間,gg.PLATEID,min(gg.Second) 秒數
                                            from ( 
                                            select a.RECEIVEDATE ins,b.RECEIVEDATE outs,
                                            DateDiff(SECOND,a.RECEIVEDATE,b.RECEIVEDATE) as Second,a.PLATEID
                                            from (SELECT *
                                            FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                                            where RECEIVEDATE>='" + startDate + @"' and RECEIVEDATE<'" + endDate + @"'
                                            and [DEVICEID]='" + tempSelectETagRoad.startID + @"'
                                            ) a,(SELECT *
                                            FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                                            where RECEIVEDATE>='" + startDate + @"' and RECEIVEDATE<'" + endDate + @"'
                                            and [DEVICEID]='" + tempSelectETagRoad.endID + @"'
                                            ) b 
                                            where a.PLATEID=b.PLATEID
                                            and DateDiff(SECOND,a.RECEIVEDATE,b.RECEIVEDATE)>0
                                            ) gg
                                            group by gg.PLATEID,gg.outs
                                            order by gg.outs";
                var 旅行時間 = DB.ExecuteQuery<旅行時間>(excelsql);

                基本資料.Add("baseInfo", baseInfo);
                基本資料.Add("report", 報表.報表);
                基本資料.Add("reportBase", 旅行時間);
                result.Add(基本資料);

            }
            var update = (from b in DB2.Report
                          where b.ReportID == reportid
                          select b).FirstOrDefault();
            update.Context = JsonConvert.SerializeObject(result);
            update.EndDate = DateTime.Now;
            DB2.SubmitChanges();
        }
    }



    public class eTag基本資料
    {
        public string StartID;
        public string EndID;
        public string RoadName;
        public string Date;
    }

    public class eTag分時旅行時間
    {
        public string Hour;
        public int Avg;
        public int Min;
        public int Max;
        public int CarNum;
    }

    public class 旅行時間
    {
        public DateTime 進來時間;
        public DateTime 離開時間;
        public int 秒數;
        public string PLATEID;
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

    public class eTag分時流量報表
    {
        public List<eTag分時旅行報表Row> 報表;

        public eTag分時流量報表()
        {
            報表 = new List<eTag分時旅行報表Row>();
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
        }
    }


    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}