<%@ WebHandler Language="C#" Class="home" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;
using KaiValid;
using KaiClass;

public class home : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        var taiwanCalendar = new System.Globalization.TaiwanCalendar();
        DataClasses3DataContext DB = new DataClasses3DataContext();
        string type = context.Items["type"].ToString();
        string str = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
        string 指定日期 = DateProcess.民國年轉西元年回傳字串格式(str);
        string 指定日期明天 = DateProcess.民國年轉西元年回傳日期格式(str).AddDays(1).ToString("yyyyMMdd");
        string 前一小時 = DateTime.Now.AddHours(-1).ToString("yyyyMMdd HH:mm");
        if (type.Equals("進出入統計"))
        {
            //哈馬星進1001,1003,1008
            //哈馬星出1002,1004,1007             

            string sql = @"SELECT (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + 指定日期 + @"' and RECEIVEDATE<'" + 指定日期明天 + @"'
                           and (DEVICEID='1001' or DEVICEID='1003' or DEVICEID='1008')
                           ) as 進入,
                           (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + 指定日期 + @"' and RECEIVEDATE<'" + 指定日期明天 + @"'
                           and (DEVICEID='1002' or DEVICEID='1004' or DEVICEID='1007')
                           ) as 離開,
                           (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + 前一小時 + @"' 
                           and (DEVICEID='1001' or DEVICEID='1003' or DEVICEID='1008')
                           ) as 一小時內進入,
                           (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + 前一小時 + @"' 
                           and (DEVICEID='1002' or DEVICEID='1004' or DEVICEID='1007')
                           ) as 一小時內離開";

            var temp = DB.ExecuteQuery<進出入統計>(sql).First();

            Dictionary<string, dynamic> temp_1 = new Dictionary<string, dynamic>();
            temp_1.Add("ComeNum", temp.進入);
            temp_1.Add("LeaveNum", temp.離開);
            temp_1.Add("StopNum", temp.進入 - temp.離開 + 700);
            temp_1.Add("HComeNum", temp.一小時內進入);
            temp_1.Add("HLeaveNum", temp.一小時內離開);
            temp_1.Add("HStopNum", temp.一小時內進入 - temp.一小時內離開 + 700);

            //西子灣進1007
            //西子灣出1008
            sql = @"SELECT (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + 指定日期 + @"' and RECEIVEDATE<'" + 指定日期明天 + @"'
                           and (DEVICEID='1007')
                           ) as 進入,
                           (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + 指定日期 + @"' and RECEIVEDATE<'" + 指定日期明天 + @"'
                           and (DEVICEID='1008')
                           ) as 離開,
                           (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + 前一小時 + @"' and (DEVICEID='1007')
                           ) as 一小時內進入,
                           (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + 前一小時 + @"' and (DEVICEID='1008')
                           ) as 一小時內離開";

            var temp2 = DB.ExecuteQuery<進出入統計>(sql).First();

            Dictionary<string, dynamic> temp_2 = new Dictionary<string, dynamic>();
            temp_2.Add("ComeNum", temp2.進入);
            temp_2.Add("LeaveNum", temp2.離開);
            temp_2.Add("StopNum", temp2.進入 - temp2.離開);
            temp_2.Add("HComeNum", temp2.一小時內進入);
            temp_2.Add("HLeaveNum", temp2.一小時內離開);
            temp_2.Add("HStopNum", temp2.一小時內進入 - temp2.一小時內離開);


            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("One", temp_1);
            result.Add("Two", temp_2);

            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("各小時進出入累積統計"))
        {
            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            //哈馬星進入1001,1003,1008
            //哈馬星離開1002,1004,1007
            var tempResult = DB.ExecuteQuery<進出入統計>(@"
                       SELECT n.Hour as 小時,case when n.ComeNums is null then 0 else n.ComeNums end as 進入
                       ,case when n.LeaveNums is null then 0 else n.LeaveNums end as 離開
                       FROM (
                       select k.Hour,k.ComeNums,s.LeaveNums
                       from (SELECT datepart(hh,RECEIVEDATE) Hour,
                       count(*) ComeNums
                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] d
                       where RECEIVEDATE>='" + 指定日期 + @"' and RECEIVEDATE<'" + 指定日期明天 + @"'
                       and (DEVICEID='1001' or DEVICEID='1003' or DEVICEID='1008')
                       group by datepart(hh,RECEIVEDATE)) k 
                       left join (SELECT datepart(hh,RECEIVEDATE) Hour,
                       count(*) LeaveNums
                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] d
                       where RECEIVEDATE>='" + 指定日期 + @"' and RECEIVEDATE<'" + 指定日期明天 + @"'
                       and (DEVICEID='1002' or DEVICEID='1004' or DEVICEID='1007')
                       group by datepart(hh,RECEIVEDATE)) s on s.Hour=k.Hour) n");

            List<ComeLeaveCount> 哈瑪星累積統計 = new List<ComeLeaveCount>();
            List<ComeLeaveCount> 哈瑪星分時統計 = new List<ComeLeaveCount>();
            int 累積進入計算 = 0;
            int 累積離開計算 = 0;
            foreach (var temp in tempResult)
            {
                ComeLeaveCount 累積統計_1 = new ComeLeaveCount();
                ComeLeaveCount 分時統計_1 = new ComeLeaveCount();
                累積進入計算 = 累積進入計算 + temp.進入;
                累積離開計算 = 累積離開計算 + temp.離開;
                if (temp.小時 < 9)
                {
                    累積統計_1.Hour = "0" + temp.小時 + "-0" + (temp.小時 + 1);
                    分時統計_1.Hour = "0" + temp.小時 + "-0" + (temp.小時 + 1);

                }
                else if (temp.小時 == 9)
                {
                    累積統計_1.Hour = "0" + temp.小時 + "-" + (temp.小時 + 1);
                    分時統計_1.Hour = "0" + temp.小時 + "-" + (temp.小時 + 1);

                }
                else
                {
                    累積統計_1.Hour = temp.小時 + "-" + (temp.小時 + 1);
                    分時統計_1.Hour = temp.小時 + "-" + (temp.小時 + 1);

                }
                累積統計_1.ComeNums = 累積進入計算;
                累積統計_1.LeaveNums = 累積離開計算;
                累積統計_1.StopNums = 累積統計_1.ComeNums - 累積統計_1.LeaveNums + 700;
                分時統計_1.ComeNums = temp.進入;
                分時統計_1.LeaveNums = temp.離開;
                分時統計_1.StopNums = 分時統計_1.ComeNums - 分時統計_1.LeaveNums;
                哈瑪星累積統計.Add(累積統計_1);
                哈瑪星分時統計.Add(分時統計_1);
            }

            result.Add("HamaxingCount", 哈瑪星累積統計);
            result.Add("HamaxingHourCount", 哈瑪星分時統計);

            var tempResult2 = DB.ExecuteQuery<進出入統計>(@"
                       SELECT n.Hour as 小時,case when n.ComeNums is null then 0 else n.ComeNums end as 進入
                       ,case when n.LeaveNums is null then 0 else n.LeaveNums end as 離開
                       FROM (
                       select k.Hour,k.ComeNums,s.LeaveNums
                       from (SELECT datepart(hh,RECEIVEDATE) Hour,
                       count(*) ComeNums
                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] d
                       where RECEIVEDATE>='" + 指定日期 + @"' and RECEIVEDATE<'" + 指定日期明天 + @"'
                       and (DEVICEID='1007')
                       group by datepart(hh,RECEIVEDATE)) k 
                       left join (SELECT datepart(hh,RECEIVEDATE) Hour,
                       count(*) LeaveNums
                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] d
                       where RECEIVEDATE>='" + 指定日期 + @"' and RECEIVEDATE<'" + 指定日期明天 + @"'
                       and (DEVICEID='1008')
                       group by datepart(hh,RECEIVEDATE)) s on s.Hour=k.Hour) n");

            List<ComeLeaveCount> 西子灣累積統計 = new List<ComeLeaveCount>();
            List<ComeLeaveCount> 西子灣分時統計 = new List<ComeLeaveCount>();

            累積進入計算 = 0;
            累積離開計算 = 0;

            foreach (var temp in tempResult2)
            {
                ComeLeaveCount 累積統計_1 = new ComeLeaveCount();
                ComeLeaveCount 分時統計_1 = new ComeLeaveCount();
                累積進入計算 = 累積進入計算 + temp.進入;
                累積離開計算 = 累積離開計算 + temp.離開;
                if (temp.小時 < 9)
                {
                    累積統計_1.Hour = "0" + temp.小時 + "-0" + (temp.小時 + 1);
                    分時統計_1.Hour = "0" + temp.小時 + "-0" + (temp.小時 + 1);

                }
                else if (temp.小時 == 9)
                {
                    累積統計_1.Hour = "0" + temp.小時 + "-" + (temp.小時 + 1);
                    分時統計_1.Hour = "0" + temp.小時 + "-" + (temp.小時 + 1);

                }
                else
                {
                    累積統計_1.Hour = temp.小時 + "-" + (temp.小時 + 1);
                    分時統計_1.Hour = temp.小時 + "-" + (temp.小時 + 1);

                }
                累積統計_1.ComeNums = 累積進入計算;
                累積統計_1.LeaveNums = 累積離開計算;
                累積統計_1.StopNums = 累積統計_1.ComeNums - 累積統計_1.LeaveNums + 700;
                分時統計_1.ComeNums = temp.進入;
                分時統計_1.LeaveNums = temp.離開;
                分時統計_1.StopNums = 分時統計_1.ComeNums - 分時統計_1.LeaveNums;
                西子灣累積統計.Add(累積統計_1);
                西子灣分時統計.Add(分時統計_1);
            }
            result.Add("SiziwanCount", 西子灣累積統計);
            result.Add("SiziwanHourCount", 西子灣分時統計);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("各eTag累積統計"))
        {
            string sql = @"select b.id as DeviceID,b.px,b.py,case when a.Nums is null then 0 else a.Nums end as Nums,b.roadname as RoadName from 
                            [UTCS_Base_KS].[dbo].[ETAG_INFO] b  left join 
                            (SELECT DEVICEID as DeviceID,count(*) as Nums
                            FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                            where RECEIVEDATE>='" + 指定日期 + @"' and RECEIVEDATE<'" + 指定日期明天 + @"'
                            group by [DEVICEID]) a  on a.DEVICEID=b.id";
            var 各eTag統計 = DB.ExecuteQuery<eTag統計>(sql);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(各eTag統計));
        }
        else
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("什麼都沒有唷");
        }
    }

    public class 進出入統計
    {
        public int 進入;
        public int 離開;
        public int 滯留;
        public int 小時;
        public int 一小時內進入;
        public int 一小時內離開;
        public int 一小時內滯留;
    }

    public class ComeLeaveCount
    {
        public string Hour;
        public int ComeNums;
        public int LeaveNums;
        public int StopNums;
    }

    public class eTag統計
    {
        public string DeviceID;
        public int Nums;
        public string RoadName;
        public double px;
        public double py;
    }


    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}