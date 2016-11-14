<%@ WebHandler Language="C#" Class="GetETag" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;
using KaiValid;
using KaiClass;

public class GetETag : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        var taiwanCalendar = new System.Globalization.TaiwanCalendar();

        DataClasses3DataContext DB = new DataClasses3DataContext();
        string type = context.Items["type"].ToString();
        ValidJson kaiValid = new ValidJson(context);
        if (type.Equals("ETagDataTodayNum"))
        {
            string str = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            int[] Nums = new int[24];
            string today = getChangeDate(str);
            string tommow = getChangeDate2(str);
            string nowHour = DateTime.Now.AddHours(-1).ToString("yyyyMMdd HH:mm");

            string sql = @"SELECT (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                           and (DEVICEID='1001' or DEVICEID='1003' or DEVICEID='1008')
                           ) as OneComeNum,
                           (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                           and (DEVICEID='1002' or DEVICEID='1004' or DEVICEID='1007')
                           ) as OneLeaveNum,
                           (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + nowHour + @"' 
                           and (DEVICEID='1001' or DEVICEID='1003' or DEVICEID='1008')
                           ) as OneHComeNum,
                           (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + nowHour + @"' 
                           and (DEVICEID='1002' or DEVICEID='1004' or DEVICEID='1007')
                           ) as OneHLeaveNum";
            var ETagDataTodayNum = DB.ExecuteQuery<ETagDataTodayNum>(sql).First();


            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("OneComeNum", ETagDataTodayNum.OneComeNum);
            result.Add("OneLeaveNum", ETagDataTodayNum.OneLeaveNum);
            result.Add("OneStopNum", ETagDataTodayNum.OneComeNum - ETagDataTodayNum.OneLeaveNum + 700);
            result.Add("OneHComeNum", ETagDataTodayNum.OneHComeNum);
            result.Add("OneHLeaveNum", ETagDataTodayNum.OneHLeaveNum);
            result.Add("OneHStopNum", ETagDataTodayNum.OneHComeNum - ETagDataTodayNum.OneHLeaveNum + 700);


            string sqlx2 = @"SELECT (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                           and (DEVICEID='1007')
                           ) as OneComeNum,
                           (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                           and (DEVICEID='1008')
                           ) as OneLeaveNum,
                           (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + nowHour + @"' and (DEVICEID='1007')
                           ) as OneHComeNum,
                           (SELECT count(*)
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + nowHour + @"' and (DEVICEID='1008')
                           ) as OneHLeaveNum";
            var ETagDataTodayNum2 = DB.ExecuteQuery<ETagDataTodayNum>(sqlx2).First();

            result.Add("OneComeNum2", ETagDataTodayNum2.OneComeNum);
            result.Add("OneLeaveNum2", ETagDataTodayNum2.OneLeaveNum);
            result.Add("OneStopNum2", ETagDataTodayNum2.OneComeNum - ETagDataTodayNum2.OneLeaveNum);
            result.Add("OneHComeNum2", ETagDataTodayNum2.OneHComeNum);
            result.Add("OneHLeaveNum2", ETagDataTodayNum2.OneHLeaveNum);
            result.Add("OneHStopNum2", ETagDataTodayNum2.OneHComeNum - ETagDataTodayNum2.OneHLeaveNum);

            var tempResult = DB.ExecuteQuery<HomeTemp1>(@"
                    SELECT n.Hour,case when n.ComeNums is null then 0 else n.ComeNums end as ComeNums
                    ,case when n.LeaveNums is null then 0 else n.LeaveNums end as LeaveNums
                    FROM (
                    select k.Hour,k.ComeNums,s.LeaveNums
                    from (SELECT datepart(hh,RECEIVEDATE) Hour,
                    count(*) ComeNums
                    FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] d
                    where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                    and (DEVICEID='1001' or DEVICEID='1003' or DEVICEID='1008')
                    group by datepart(hh,RECEIVEDATE)) k 
					left join (SELECT datepart(hh,RECEIVEDATE) Hour,
                    count(*) LeaveNums
                    FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] d
                    where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                    and (DEVICEID='1002' or DEVICEID='1004' or DEVICEID='1007')
                    group by datepart(hh,RECEIVEDATE)) s on s.Hour=k.Hour) n");

            List<HomeChart1> HomeChart1 = new List<HomeChart1>();
            List<HomeChart1> HomeChart2 = new List<HomeChart1>();
            int HomeChart1Num1 = 0;
            int HomeChart1Num2 = 0;
            foreach (var temp in tempResult)
            {
                HomeChart1 temp1 = new HomeChart1();
                HomeChart1 temp2 = new HomeChart1();
                HomeChart1Num1 = HomeChart1Num1 + temp.ComeNums;
                HomeChart1Num2 = HomeChart1Num2 + temp.LeaveNums;
                if (temp.Hour < 9)
                {
                    temp1.Hour = "0" + temp.Hour + "-0" + (temp.Hour + 1);
                    temp2.Hour = "0" + temp.Hour + "-0" + (temp.Hour + 1);

                }
                else if (temp.Hour == 9)
                {
                    temp1.Hour = "0" + temp.Hour + "-" + (temp.Hour + 1);
                    temp2.Hour = "0" + temp.Hour + "-" + (temp.Hour + 1);

                }
                else
                {
                    temp1.Hour = temp.Hour + "-" + (temp.Hour + 1);
                    temp2.Hour = temp.Hour + "-" + (temp.Hour + 1);

                }
                temp1.ComeNums = HomeChart1Num1;
                temp1.LeaveNums = HomeChart1Num2;
                temp1.StopNums = temp1.ComeNums - temp1.LeaveNums + 700;
                temp2.ComeNums = temp.ComeNums;
                temp2.LeaveNums = temp.LeaveNums;
                temp2.StopNums = temp2.ComeNums - temp2.LeaveNums;
                HomeChart1.Add(temp1);
                HomeChart2.Add(temp2);
            }
            result.Add("HomeChart1", HomeChart1);
            result.Add("HomeChart2", HomeChart2);


            var tempResult2 = DB.ExecuteQuery<HomeTemp1>(@"
                    SELECT n.Hour,case when n.ComeNums is null then 0 else n.ComeNums end as ComeNums
                    ,case when n.LeaveNums is null then 0 else n.LeaveNums end as LeaveNums
                    FROM (
                    select k.Hour,k.ComeNums,s.LeaveNums
                    from (SELECT datepart(hh,RECEIVEDATE) Hour,
                    count(*) ComeNums
                    FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] d
                    where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                    and (DEVICEID='1007')
                    group by datepart(hh,RECEIVEDATE)) k 
					left join (SELECT datepart(hh,RECEIVEDATE) Hour,
                    count(*) LeaveNums
                    FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] d
                    where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                    and (DEVICEID='1008')
                    group by datepart(hh,RECEIVEDATE)) s on s.Hour=k.Hour) n");

            List<HomeChart1> HomeChart3 = new List<HomeChart1>();
            List<HomeChart1> HomeChart4 = new List<HomeChart1>();
            int HomeChart1Num3 = 0;
            int HomeChart1Num4 = 0;
            foreach (var temp in tempResult2)
            {
                HomeChart1 temp1 = new HomeChart1();
                HomeChart1 temp2 = new HomeChart1();
                HomeChart1Num3 = HomeChart1Num3 + temp.ComeNums;
                HomeChart1Num4 = HomeChart1Num4 + temp.LeaveNums;
                if (temp.Hour < 9)
                {
                    temp1.Hour = "0" + temp.Hour + "-0" + (temp.Hour + 1);
                    temp2.Hour = "0" + temp.Hour + "-0" + (temp.Hour + 1);

                }
                else if (temp.Hour == 9)
                {
                    temp1.Hour = "0" + temp.Hour + "-" + (temp.Hour + 1);
                    temp2.Hour = "0" + temp.Hour + "-" + (temp.Hour + 1);

                }
                else
                {
                    temp1.Hour = temp.Hour + "-" + (temp.Hour + 1);
                    temp2.Hour = temp.Hour + "-" + (temp.Hour + 1);

                }
                temp1.ComeNums = HomeChart1Num3;
                temp1.LeaveNums = HomeChart1Num4;
                temp1.StopNums = temp1.ComeNums - temp1.LeaveNums;
                temp2.ComeNums = temp.ComeNums;
                temp2.LeaveNums = temp.LeaveNums;
                temp2.StopNums = temp2.ComeNums - temp2.LeaveNums;
                HomeChart3.Add(temp1);
                HomeChart4.Add(temp2);
            }
            result.Add("HomeChart3", HomeChart3);
            result.Add("HomeChart4", HomeChart4);


            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("ETagDataTodayNum2"))
        {
            string str = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            string today = getChangeDate(str);
            string tommow = getChangeDate2(str);
            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();

            string sql2 = @"select b.id as DeviceID,case when a.Nums is null then 0 else a.Nums end as Nums,b.roadname as RoadName from 
                            [UTCS_Base_KS].[dbo].[ETAG_INFO] b  left join 
                            ( SELECT DEVICEID as DeviceID,count(*) as Nums
                            FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                            where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                            group by [DEVICEID]) a  on a.DEVICEID=b.id";
            var TopETagNum = DB.ExecuteQuery<TopETagNum>(sql2);

            result.Add("TopETagNum", TopETagNum);

            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("chart1"))
        {
            string str = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            int[] Nums = new int[24];
            string today = getChangeDate(str);
            string tommow = getChangeDate2(str);
            string nowHour = DateTime.Now.AddHours(-1).ToString("yyyyMMdd HH:mm");
            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();

            var tempResult = DB.ExecuteQuery<HomeTemp1>(@"
                    SELECT n.Hour,case when n.ComeNums is null then 0 else n.ComeNums end as ComeNums
                    ,case when n.LeaveNums is null then 0 else n.LeaveNums end as LeaveNums
                    FROM (
                    select k.Hour,k.ComeNums,s.LeaveNums
                    from (SELECT datepart(hh,RECEIVEDATE) Hour,
                    count(*) ComeNums
                    FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] d
                    where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                    and (DEVICEID='1001' or DEVICEID='1003' or DEVICEID='1008')
                    group by datepart(hh,RECEIVEDATE)) k 
					left join (SELECT datepart(hh,RECEIVEDATE) Hour,
                    count(*) LeaveNums
                    FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] d
                    where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                    and (DEVICEID='1002' or DEVICEID='1004' or DEVICEID='1007')
                    group by datepart(hh,RECEIVEDATE)) s on s.Hour=k.Hour) n");

            List<HomeChart1> HomeChart1 = new List<HomeChart1>();
            List<HomeChart1> HomeChart2 = new List<HomeChart1>();
            int HomeChart1Num1 = 0;
            int HomeChart1Num2 = 0;
            int thisHour = 0;
            foreach (var temp in tempResult)
            {
                while (thisHour != temp.Hour)
                {
                    HomeChart1 temp1x = new HomeChart1();
                    HomeChart1 temp2x = new HomeChart1();
                    if (thisHour < 9)
                    {
                        temp1x.Hour = "0" + thisHour + "-0" + (thisHour + 1);
                        temp2x.Hour = "0" + thisHour + "-0" + (thisHour + 1);

                    }
                    else if (thisHour == 9)
                    {
                        temp1x.Hour = "0" + thisHour + "-" + (thisHour + 1);
                        temp2x.Hour = "0" + thisHour + "-" + (thisHour + 1);

                    }
                    else
                    {
                        temp1x.Hour = thisHour + "-" + (thisHour + 1);
                        temp2x.Hour = thisHour + "-" + (thisHour + 1);

                    }
                    temp1x.ComeNums = 0;
                    temp1x.LeaveNums = 0;
                    temp1x.StopNums = 0;
                    temp2x.ComeNums = 0;
                    temp2x.LeaveNums = 0;
                    temp2x.StopNums = 0;
                    HomeChart1.Add(temp1x);
                    HomeChart2.Add(temp2x);
                    thisHour = thisHour + 1;
                }
                HomeChart1 temp1 = new HomeChart1();
                HomeChart1 temp2 = new HomeChart1();
                HomeChart1Num1 = HomeChart1Num1 + temp.ComeNums;
                HomeChart1Num2 = HomeChart1Num2 + temp.LeaveNums;
                if (temp.Hour < 9)
                {
                    temp1.Hour = "0" + temp.Hour + "-0" + (temp.Hour + 1);
                    temp2.Hour = "0" + temp.Hour + "-0" + (temp.Hour + 1);

                }
                else if (temp.Hour == 9)
                {
                    temp1.Hour = "0" + temp.Hour + "-" + (temp.Hour + 1);
                    temp2.Hour = "0" + temp.Hour + "-" + (temp.Hour + 1);

                }
                else
                {
                    temp1.Hour = temp.Hour + "-" + (temp.Hour + 1);
                    temp2.Hour = temp.Hour + "-" + (temp.Hour + 1);
                }
                temp1.ComeNums = HomeChart1Num1;
                temp1.LeaveNums = HomeChart1Num2;
                temp1.StopNums = temp1.ComeNums - temp1.LeaveNums + 700;
                temp2.ComeNums = temp.ComeNums;
                temp2.LeaveNums = temp.LeaveNums;
                temp2.StopNums = temp2.ComeNums - temp2.LeaveNums;
                HomeChart1.Add(temp1);
                HomeChart2.Add(temp2);
                thisHour = thisHour + 1;
            }
            result.Add("HomeChart1", HomeChart1);
            result.Add("HomeChart2", HomeChart2);


            List<dynamic> road1 = new List<dynamic>();
            for (int i = 0; i < 24; i++)
            {

                string tempHour = "";
                if (i < 9)
                {
                    tempHour = "0" + i + "-0" + (i + 1);
                    tempHour = "0" + i + "-0" + (i + 1);

                }
                else if (i == 9)
                {
                    tempHour = "0" + i + "-" + (i + 1);

                }
                else
                {
                    tempHour = i + "-" + (i + 1);
                }
                string sql2 = @"select case when AVG(x.Second) is null then 0 else AVG(x.Second) end as Avg,
                                       case when Min(x.Second) is null then 0 else Min(x.Second) end as Min,
                                       case when Max(x.Second) is null then 0 else Max(x.Second) end as Max,'" + tempHour + @"' Hour,
                                       count(*) as carNum
                                       from (select w.Hour,MIN(w.Second) as Second,w.PLATEID
                                       from (select datepart(hh,b.RECEIVEDATE) Hour,
                                       DateDiff(SECOND,a.RECEIVEDATE,b.RECEIVEDATE) as Second,a.PLATEID
                                       from (SELECT *
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                                       where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                                       and [DEVICEID]='1001'
                                       ) a,(SELECT *
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                                       where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                                       and datepart(hh,RECEIVEDATE)=" + i + @"
                                       and [DEVICEID]='1007'
                                       ) b 
                                       where a.PLATEID=b.PLATEID) w
                                       where w.Second>0 and 
                                       w.Second<" + (3.9 * 60) + @" and w.Second>" + (0.56 * 60) + @"
                                       group by w.PLATEID,w.Hour							
                                       ) x";
                var gogoTime1 = DB.ExecuteQuery<gogoTime>(sql2);
                road1.Add(gogoTime1);

            }
            result.Add("road1", road1);
            List<dynamic> road2 = new List<dynamic>();
            for (int i = 0; i < 24; i++)
            {

                string tempHour = "";
                if (i < 9)
                {
                    tempHour = "0" + i + "-0" + (i + 1);
                    tempHour = "0" + i + "-0" + (i + 1);

                }
                else if (i == 9)
                {
                    tempHour = "0" + i + "-" + (i + 1);

                }
                else
                {
                    tempHour = i + "-" + (i + 1);
                }

                string sql2 = @"select case when AVG(x.Second) is null then 0 else AVG(x.Second) end as Avg,
                                       case when Min(x.Second) is null then 0 else Min(x.Second) end as Min,
                                       case when Max(x.Second) is null then 0 else Max(x.Second) end as Max,'" + tempHour + @"' Hour,
                                       count(*) as carNum
                                       from (select w.Hour,MIN(w.Second) as Second,w.PLATEID
                                       from (select datepart(hh,b.RECEIVEDATE) Hour,
                                       DateDiff(SECOND,a.RECEIVEDATE,b.RECEIVEDATE) as Second,a.PLATEID
                                       from (SELECT *
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                                       where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                                       and [DEVICEID]='1008'
                                       ) a,(SELECT *
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                                       where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                                       and datepart(hh,RECEIVEDATE)=" + i + @"
                                       and [DEVICEID]='1002'
                                       ) b 
                                       where a.PLATEID=b.PLATEID) w
                                       where w.Second>0 and 
                                       w.Second<" + (3.9 * 60) + @" and w.Second>" + (0.56 * 60) + @"
                                       group by w.PLATEID,w.Hour							
                                       ) x";
                var gogoTime1 = DB.ExecuteQuery<gogoTime>(sql2);
                road2.Add(gogoTime1);

            }
            result.Add("road2", road2);

            List<dynamic> road3 = new List<dynamic>();
            for (int i = 0; i < 24; i++)
            {

                string tempHour = "";
                if (i < 9)
                {
                    tempHour = "0" + i + "-0" + (i + 1);
                    tempHour = "0" + i + "-0" + (i + 1);

                }
                else if (i == 9)
                {
                    tempHour = "0" + i + "-" + (i + 1);

                }
                else
                {
                    tempHour = i + "-" + (i + 1);
                }

                string sql2 = @"select case when AVG(x.Second) is null then 0 else AVG(x.Second) end as Avg,
                                       case when Min(x.Second) is null then 0 else Min(x.Second) end as Min,
                                       case when Max(x.Second) is null then 0 else Max(x.Second) end as Max,'" + tempHour + @"' Hour,
                                       count(*) as carNum
                                       from (select w.Hour,MIN(w.Second) as Second,w.PLATEID
                                       from (select datepart(hh,b.RECEIVEDATE) Hour,
                                       DateDiff(SECOND,a.RECEIVEDATE,b.RECEIVEDATE) as Second,a.PLATEID
                                       from (SELECT *
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                                       where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                                       and [DEVICEID]='1003'
                                       ) a,(SELECT *
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                                       where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                                       and datepart(hh,RECEIVEDATE)=" + i + @"
                                       and [DEVICEID]='1007'
                                       ) b 
                                       where a.PLATEID=b.PLATEID) w
                                       where w.Second>0 and 
                                       w.Second<" + (6.6 * 60) + @" and w.Second>" + (0.94 * 60) + @"
                                       group by w.PLATEID,w.Hour							
                                       ) x";
                var gogoTime1 = DB.ExecuteQuery<gogoTime>(sql2);
                road3.Add(gogoTime1);

            }
            result.Add("road3", road3);

            List<dynamic> road4 = new List<dynamic>();
            for (int i = 0; i < 24; i++)
            {

                string tempHour = "";
                if (i < 9)
                {
                    tempHour = "0" + i + "-0" + (i + 1);
                    tempHour = "0" + i + "-0" + (i + 1);

                }
                else if (i == 9)
                {
                    tempHour = "0" + i + "-" + (i + 1);

                }
                else
                {
                    tempHour = i + "-" + (i + 1);
                }

                string sql2 = @"select case when AVG(x.Second) is null then 0 else AVG(x.Second) end as Avg,
                                       case when Min(x.Second) is null then 0 else Min(x.Second) end as Min,
                                       case when Max(x.Second) is null then 0 else Max(x.Second) end as Max,'" + tempHour + @"' Hour,
                                       count(*) as carNum
                                       from (select w.Hour,MIN(w.Second) as Second,w.PLATEID
                                       from (select datepart(hh,b.RECEIVEDATE) Hour,
                                       DateDiff(SECOND,a.RECEIVEDATE,b.RECEIVEDATE) as Second,a.PLATEID
                                       from (SELECT *
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                                       where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                                       and [DEVICEID]='1008'
                                       ) a,(SELECT *
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE] 
                                       where RECEIVEDATE>='" + today + @"' and RECEIVEDATE<'" + tommow + @"'
                                       and datepart(hh,RECEIVEDATE)=" + i + @"
                                       and [DEVICEID]='1004'
                                       ) b 
                                       where a.PLATEID=b.PLATEID) w
                                       where w.Second>0 and 
                                       w.Second<" + (6.6 * 60) + @" and w.Second>" + (0.94 * 60) + @"
                                       group by w.PLATEID,w.Hour							
                                       ) x";
                var gogoTime1 = DB.ExecuteQuery<gogoTime>(sql2);
                road4.Add(gogoTime1);

            }
            result.Add("road4", road4);

            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("eTagTimeFlowWeek"))
        {
            dynamic json = kaiValid.tranResToDynamic();
            DateTime startDate = startDateTr(json.startDate);
            DateTime endDate = endDateTr2(json.endDate);
            string selectLocation = json.location;
            int lowNum = Convert.ToInt32(json.lowNum);
            string device1 = "";
            string device2 = "";
            if (selectLocation.Equals("1"))
            {
                device1 = "0001";
                device2 = "0002";
            }
            else if (selectLocation.Equals("2"))
            {
                device1 = "0003";
                device2 = "0004";
            }
            else if (selectLocation.Equals("3"))
            {
                device1 = "0005";
                device2 = "0006";
            }
            else if (selectLocation.Equals("4"))
            {
                device1 = "0007";
                device2 = "0008";
            }


            string sql = @"SELECT CONVERT(varchar(100),RECEIVEDATE, 112) Ndate,
                           DatePart(WeekDay,RECEIVEDATE) DayOfWeek,
                           datepart(hh,RECEIVEDATE) Hour,
                           DEVICEID,
                           count(*) Nums
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where [RECEIVEDATE]>'" + startDate.ToString("yyyy-MM-dd") + @"'
                           and [RECEIVEDATE]<'" + endDate.ToString("yyyy-MM-dd") + @"'  
                           and (DEVICEID = '" + device1 + @"' or DEVICEID ='" + device2 + @"')
                           group by CONVERT(varchar(100),RECEIVEDATE, 112),
                           DatePart(WeekDay,RECEIVEDATE),datepart(hh,RECEIVEDATE),
                           DEVICEID";

            var tempResult1 = DB.ExecuteQuery<weekDayNum>(sql);

            string sql2 = @"SELECT CONVERT(varchar(100),RECEIVEDATE, 112) Ndate,
                           DatePart(WeekDay,RECEIVEDATE) DayOfWeek,
                           datepart(hh,RECEIVEDATE) Hour,
                           DEVICEID,
                           count(*) Nums
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where [RECEIVEDATE]>'" + startDate.ToString("yyyy-MM-dd") + @"'
                           and [RECEIVEDATE]<'" + endDate.ToString("yyyy-MM-dd") + @"'  
                           and (DEVICEID = '" + device1 + @"' or DEVICEID ='" + device2 + @"')
                           and substring(PLATEID,6,1)!='3'
                           group by CONVERT(varchar(100),RECEIVEDATE, 112),
                           DatePart(WeekDay,RECEIVEDATE),datepart(hh,RECEIVEDATE),
                           DEVICEID";


            var tempResult2 = DB.ExecuteQuery<weekDayNum>(sql2);



            var tempResult = from a in tempResult1
                             join b in tempResult2
                             on new { DayOfWeek = a.DayOfWeek, DEVICEID = a.DEVICEID, Hour = a.Hour, Ndate = a.Ndate }
                             equals
                             new { b.DayOfWeek, b.DEVICEID, b.Hour, b.Ndate } into subGrp
                             from b in subGrp.DefaultIfEmpty()
                             select new
                             {
                                 a.Ndate,
                                 a.DEVICEID,
                                 a.DayOfWeek,
                                 a.Hour,
                                 AllNums = a.Nums,
                                 BNums = (b == null ? 0 : b.Nums)
                             };



            Dictionary<string, dynamic> result1 = new Dictionary<string, dynamic>();
            List<eTagTimeFlowWeek>[] result = new List<eTagTimeFlowWeek>[7];
            for (int i = 0; i < 7; i++)
            {
                result[i] = new List<eTagTimeFlowWeek>();
                for (int j = 0; j < 24; j++)
                {
                    eTagTimeFlowWeek temp = new eTagTimeFlowWeek();
                    if (j.ToString().Length == 1)
                    {
                        if (j == 9)
                        {
                            temp.Hour = "0" + j + ":00 - " + (j + 1) + ":00";
                        }
                        else
                        {
                            temp.Hour = "0" + j + ":00 - 0" + (j + 1) + ":00";
                        }
                    }
                    else
                    {
                        temp.Hour = j + ":00 - " + (j + 1) + ":00";
                    }
                    result[i].Add(temp);
                }
            }
            int[,] av1 = new int[7, 24];
            int[,] av2 = new int[7, 24];
            for (int i = 0; i < 7; i++)
            {
                for (int j = 0; j < 24; j++)
                {
                    av1[i, j] = 0;
                    av2[i, j] = 0;
                }
            }
            foreach (var temp in tempResult)
            {
                if (temp.AllNums > lowNum)
                {
                    int tempWeek = temp.DayOfWeek - 1;
                    if (temp.DEVICEID.Equals(device1))
                    {

                        result[tempWeek][temp.Hour].BOneNum = result[tempWeek][temp.Hour].BOneNum + Convert.ToInt32(temp.BNums);
                        result[tempWeek][temp.Hour].SOneNum = result[tempWeek][temp.Hour].SOneNum + (temp.AllNums - Convert.ToInt32(temp.BNums));
                        av1[tempWeek, temp.Hour] = av1[tempWeek, temp.Hour] + 1;

                    }
                    else if (temp.DEVICEID.Equals(device2))
                    {

                        result[tempWeek][temp.Hour].BTwoNum = result[tempWeek][temp.Hour].BTwoNum + Convert.ToInt32(temp.BNums);
                        result[tempWeek][temp.Hour].STwoNum = result[tempWeek][temp.Hour].STwoNum + (temp.AllNums - Convert.ToInt32(temp.BNums));
                        av2[tempWeek, temp.Hour] = av2[tempWeek, temp.Hour] + 1;

                    }
                }
            }

            for (int i = 0; i < 7; i++)
            {
                for (int j = 0; j < 24; j++)
                {
                    int nav1 = av1[i, j] == 0 ? 1 : av1[i, j];
                    int nav2 = av2[i, j] == 0 ? 1 : av2[i, j];
                    result[i][j].SOneNum = result[i][j].SOneNum / nav1;
                    result[i][j].STwoNum = result[i][j].STwoNum / nav2;
                    result[i][j].BOneNum = result[i][j].BOneNum / nav1;
                    result[i][j].BTwoNum = result[i][j].BTwoNum / nav2;
                    result[i][j].TwoNum = result[i][j].STwoNum + result[i][j].BTwoNum;
                    result[i][j].OneNum = result[i][j].SOneNum + result[i][j].BOneNum;
                }
            }


            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("ETagBaseItem"))
        {
            var result = from a in DB.ETAG_INFO
                         orderby a.id
                         select new
                         {
                             a.id,
                             Img = "kCustom/image/map2.png",
                             Position = a.px + "," + a.py,
                             title = a.roadname,
                             choose = false
                         };
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("ETagBaseData"))
        {
            dynamic json = kaiValid.tranResToDynamic();
            string startDate = ETagBaseDataTr(json.startDate) + " " + json.startHH + ":" + json.startMM;
            string endDate = ETagBaseDataTr(json.endDate) + " " + json.endHH + ":" + json.endMM;
            string eTag = json.eTag;

            string sql = @"SELECT TOP 100000 [DEVICEID],CONVERT(varchar(100), [RECEIVEDATE], 120) RECEIVEDATE,[LANEID],[PLATEID],
                           case when SUBSTRING([PLATEID],6,1)='3' then '小型車' when SUBSTRING([PLATEID],6,1)='4' then '大型車'
                           when SUBSTRING([PLATEID],6,1)='5' then '聯結車' else '' end as CarType
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>'" + startDate + @"' and RECEIVEDATE<'" + endDate + @"'";

            if (!eTag.Equals(""))
            {
                sql = sql + "and [PLATEID]='" + eTag + "'";

            }

            bool cETag = true;
            if (json.selectETag != null)
            {
                for (int i = 0; i < 16; i++)
                {

                    if (i < 8)
                    {
                        if (cETag)
                        {
                            if ((bool)json.selectETag[i])
                            {
                                sql = sql + "and ([DEVICEID]='000" + (i + 1) + "'";

                                cETag = false;
                            }
                        }
                        else
                        {
                            if ((bool)json.selectETag[i])
                            {
                                sql = sql + "or [DEVICEID]='000" + (i + 1) + "'";
                            }
                        }
                    }
                    else
                    {
                        if (cETag)
                        {
                            if ((bool)json.selectETag[i])
                            {
                                sql = sql + "and ([DEVICEID]='100" + (i - 7) + "'";

                                cETag = false;
                            }
                        }
                        else
                        {
                            if ((bool)json.selectETag[i])
                            {
                                sql = sql + "or [DEVICEID]='100" + (i - 7) + "'";
                            }
                        }
                    }
                }

            }
            if (!cETag)
            {
                sql = sql + ") order by RECEIVEDATE desc";
            }
            else
            {
                sql = sql + "and DEVICEID='10001123'";
            }



            var result = DB.ExecuteQuery<ETagBaseData>(sql);

            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("ETagTimeFlowOne"))
        {
            dynamic json = kaiValid.tranResToDynamic();
            DateTime startDate = startDateTr(json.startDate);
            DateTime endDate = endDateTr2(json.endDate);
            string selectLocation = json.location;
            string tempDevice = "";
            if ((bool)json.selectETag[0])
            {
                tempDevice = tempDevice + "'0001','0002',";
            }
            if ((bool)json.selectETag[1])
            {
                tempDevice = tempDevice + "'0003','0004',";
            }
            if ((bool)json.selectETag[2])
            {
                tempDevice = tempDevice + "'0005','0006',";
            }

            string sql = @"SELECT datepart(hh,RECEIVEDATE) Hour,
                           CONVERT(varchar(100), [RECEIVEDATE], 23) Date,
                           count(*) Nums
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where [RECEIVEDATE]>'" + startDate.ToString("yyyy-MM-dd") + @"'
                           and [RECEIVEDATE]<'" + endDate.ToString("yyyy-MM-dd") + @"'";

            sql = sql + @"and DEVICEID in(" + tempDevice + @"'') 
                          group by datepart(hh,RECEIVEDATE),
                          CONVERT(varchar(100), [RECEIVEDATE], 23)";


            var ETagTimeFlowOneTemp1 = DB.ExecuteQuery<ETagTimeFlowOneTemp>(sql);

            string sql2 = @"SELECT datepart(hh,RECEIVEDATE) Hour,
                           CONVERT(varchar(100), [RECEIVEDATE], 23) Date,
                           count(*) Nums
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where [RECEIVEDATE]>'" + startDate.ToString("yyyy-MM-dd") + @"'
                           and [RECEIVEDATE]<'" + endDate.ToString("yyyy-MM-dd") + @"'
                           and substring(PLATEID,6,1)!='3'";

            sql2 = sql2 + @"and DEVICEID in(" + tempDevice + @"'') 
                          group by datepart(hh,RECEIVEDATE),
                          CONVERT(varchar(100), [RECEIVEDATE], 23)";


            var ETagTimeFlowOneTemp2 = DB.ExecuteQuery<ETagTimeFlowOneTemp>(sql2);

            var tempJoinResult1 = from a in ETagTimeFlowOneTemp1
                                  join b in ETagTimeFlowOneTemp2
                                  on new { Hour = a.Hour, Date = a.Date }
                                  equals
                                  new { b.Hour, b.Date } into subGrp
                                  from b in subGrp.DefaultIfEmpty()
                                  orderby a.Date, a.Hour
                                  select new
                                  {
                                      a.Date,
                                      a.Hour,
                                      AllNums = a.Nums,
                                      BNums = (b == null ? 0 : b.Nums)
                                  };



            TimeFlowTable timeFlowNum = new TimeFlowTable("1");
            TimeFlowTable timeFlowNum2 = new TimeFlowTable("1");

            TimeFlowTableGroup result = new TimeFlowTableGroup();
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("ETagTimeFlowTwo"))
        {
            dynamic json = kaiValid.tranResToDynamic();
            DateTime startDate = startDateTr(json.startDate);
            DateTime endDate = endDateTr2(json.endDate);
            string selectLocation = json.location;
            string device1 = "";
            string device2 = "";
            if (selectLocation.Equals("1"))
            {
                device1 = "0001";
                device2 = "0002";
            }
            else if (selectLocation.Equals("2"))
            {
                device1 = "0003";
                device2 = "0004";
            }
            else if (selectLocation.Equals("3"))
            {
                device1 = "0005";
                device2 = "0006";
            }
            else if (selectLocation.Equals("4"))
            {
                device1 = "0007";
                device2 = "0008";
            }


            var tempResult = DB.ExecuteQuery<eTagTimeFlowTwo>(@"
                    SELECT datepart(hh,RECEIVEDATE) Hour,DEVICEID,
                    count(*) Nums
                    FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                    where [RECEIVEDATE]>'" + startDate.ToString("yyyy-MM-dd") + @"'
                    and [RECEIVEDATE]<'" + endDate.ToString("yyyy-MM-dd") + @"'  
                    and (DEVICEID = '" + device1 + @"' or DEVICEID ='" + device2 + @"')
                    group by datepart(hh,RECEIVEDATE),DEVICEID");

            List<timeFlow> timeFlowNum = new List<timeFlow>();
            for (int i = 0; i < 24; i++)
            {
                timeFlow temp = new timeFlow();
                if (i.ToString().Length == 1)
                {
                    if (i == 9)
                    {
                        temp.hour = "0" + i + ":00 - " + (i + 1) + ":00";
                    }
                    else
                    {
                        temp.hour = "0" + i + ":00 - 0" + (i + 1) + ":00";
                    }
                }
                else
                {
                    temp.hour = i + ":00 - " + (i + 1) + ":00";
                }
                timeFlowNum.Add(temp);
            }
            timeFlowNum.Add(new timeFlow("晨峰"));
            timeFlowNum.Add(new timeFlow("昏峰"));
            timeFlowNum.Add(new timeFlow("離峰"));
            timeFlowNum.Add(new timeFlow("全日"));


            foreach (var temp in tempResult)
            {

                for (int i = 0; i < 24; i++)
                {
                    if (i == temp.Hour)
                    {
                        if (temp.DEVICEID.Equals(device1))
                        {
                            timeFlowNum[i].oneNum = temp.Nums;

                        }
                        else if (temp.DEVICEID.Equals(device2))
                        {
                            timeFlowNum[i].twoNum = temp.Nums;
                        }
                        break;
                    }
                }
            }

            var tempResult2 = DB.ExecuteQuery<eTagTimeFlowTwo>(@"
                    SELECT datepart(hh,RECEIVEDATE) Hour,DEVICEID,
                    count(*) Nums
                    FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                    where [RECEIVEDATE]>'" + startDate.ToString("yyyy-MM-dd") + @"'
                    and [RECEIVEDATE]<'" + endDate.ToString("yyyy-MM-dd") + @"'  
                    and (DEVICEID = '" + device1 + @"' or DEVICEID ='" + device2 + @"')
                    and PLATEID not like '%46455443'
                    group by datepart(hh,RECEIVEDATE),DEVICEID");

            foreach (var temp in tempResult2)
            {
                for (int i = 0; i < 24; i++)
                {
                    if (i == temp.Hour)
                    {
                        if (temp.DEVICEID.Equals(device1))
                        {
                            timeFlowNum[i].bOneNum = temp.Nums;

                        }
                        else if (temp.DEVICEID.Equals(device2))
                        {
                            timeFlowNum[i].bTwoNum = temp.Nums;
                        }
                        break;
                    }
                }
            }
            for (int i = 0; i < 24; i++)
            {

                timeFlowNum[i].sOneNum = timeFlowNum[i].oneNum - timeFlowNum[i].bOneNum;
                timeFlowNum[i].sTwoNum = timeFlowNum[i].twoNum - timeFlowNum[i].bTwoNum;
            }



            //晨峰7-9
            timeFlowNum[24].twoNum = ((timeFlowNum[7].twoNum + timeFlowNum[8].twoNum) / 2);
            timeFlowNum[24].oneNum = (timeFlowNum[7].oneNum + timeFlowNum[8].oneNum) / 2;
            timeFlowNum[24].bTwoNum = (timeFlowNum[7].bTwoNum + timeFlowNum[8].bTwoNum) / 2;
            timeFlowNum[24].sTwoNum = (timeFlowNum[7].sTwoNum + timeFlowNum[8].sTwoNum) / 2;
            timeFlowNum[24].sOneNum = (timeFlowNum[7].sOneNum + timeFlowNum[8].sOneNum) / 2;
            timeFlowNum[24].bOneNum = (timeFlowNum[7].bOneNum + timeFlowNum[8].bOneNum) / 2;
            //昏峰17-19
            timeFlowNum[25].twoNum = (timeFlowNum[17].twoNum + timeFlowNum[18].twoNum) / 2;
            timeFlowNum[25].oneNum = (timeFlowNum[17].oneNum + timeFlowNum[18].oneNum) / 2;
            timeFlowNum[25].bTwoNum = (timeFlowNum[17].bTwoNum + timeFlowNum[18].bTwoNum) / 2;
            timeFlowNum[25].sTwoNum = (timeFlowNum[17].sTwoNum + timeFlowNum[18].sTwoNum) / 2;
            timeFlowNum[25].sOneNum = (timeFlowNum[17].sOneNum + timeFlowNum[18].sOneNum) / 2;
            timeFlowNum[25].bOneNum = (timeFlowNum[17].bOneNum + timeFlowNum[18].bOneNum) / 2;
            //離峰9-17
            for (int i = 9; i < 17; i++)
            {
                timeFlowNum[26].twoNum = timeFlowNum[26].twoNum + timeFlowNum[i].twoNum;
            }
            timeFlowNum[26].twoNum = timeFlowNum[26].twoNum / 8;

            for (int i = 9; i < 17; i++)
            {
                timeFlowNum[26].oneNum = timeFlowNum[26].oneNum + timeFlowNum[i].oneNum;
            }
            timeFlowNum[26].oneNum = timeFlowNum[26].oneNum / 8;

            for (int i = 9; i < 17; i++)
            {
                timeFlowNum[26].bTwoNum = timeFlowNum[26].bTwoNum + timeFlowNum[i].bTwoNum;
            }
            timeFlowNum[26].bTwoNum = timeFlowNum[26].bTwoNum / 8;

            for (int i = 9; i < 17; i++)
            {
                timeFlowNum[26].sTwoNum = timeFlowNum[26].sTwoNum + timeFlowNum[i].sTwoNum;
            }
            timeFlowNum[26].sTwoNum = timeFlowNum[26].sTwoNum / 8;

            for (int i = 9; i < 17; i++)
            {
                timeFlowNum[26].sOneNum = timeFlowNum[26].sOneNum + timeFlowNum[i].sOneNum;
            }
            timeFlowNum[26].sOneNum = timeFlowNum[26].sOneNum / 8;

            for (int i = 9; i < 17; i++)
            {
                timeFlowNum[26].bOneNum = timeFlowNum[26].bOneNum + timeFlowNum[i].bOneNum;
            }
            timeFlowNum[26].bOneNum = timeFlowNum[26].bOneNum / 8;

            //全日
            for (int i = 0; i < 24; i++)
            {
                timeFlowNum[27].twoNum = timeFlowNum[27].twoNum + timeFlowNum[i].twoNum;
            }
            timeFlowNum[27].twoNum = timeFlowNum[27].twoNum / 24;

            for (int i = 0; i < 24; i++)
            {
                timeFlowNum[27].oneNum = timeFlowNum[27].oneNum + timeFlowNum[i].oneNum;
            }
            timeFlowNum[27].oneNum = timeFlowNum[27].oneNum / 24;

            for (int i = 0; i < 24; i++)
            {
                timeFlowNum[27].bTwoNum = timeFlowNum[27].bTwoNum + timeFlowNum[i].bTwoNum;
            }
            timeFlowNum[27].bTwoNum = timeFlowNum[27].bTwoNum / 24;

            for (int i = 0; i < 24; i++)
            {
                timeFlowNum[27].sTwoNum = timeFlowNum[27].sTwoNum + timeFlowNum[i].sTwoNum;
            }
            timeFlowNum[27].sTwoNum = timeFlowNum[27].sTwoNum / 24;

            for (int i = 0; i < 24; i++)
            {
                timeFlowNum[27].sOneNum = timeFlowNum[27].sOneNum + timeFlowNum[i].sOneNum;
            }
            timeFlowNum[27].sOneNum = timeFlowNum[27].sOneNum / 24;

            for (int i = 0; i < 24; i++)
            {
                timeFlowNum[27].bOneNum = timeFlowNum[27].bOneNum + timeFlowNum[i].bOneNum;
            }
            timeFlowNum[27].bOneNum = timeFlowNum[27].bOneNum / 24;
            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(timeFlowNum));
        }
        else if (type.Equals("eTagAllFlow"))
        {
            dynamic json = kaiValid.tranResToDynamic();
            DateTime startDate = startDateTr(json.startDate);
            DateTime endDate = endDateTr2(json.endDate);
            string selectLocation = json.location;


            string sql = @"SELECT datepart(HH,RECEIVEDATE) Hour,datepart(mi,RECEIVEDATE)/15 Minute,
	                       count(*) Nums
	                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
	                       where [RECEIVEDATE]>'" + startDate.ToString("yyyy-MM-dd") + @"'
                           and [RECEIVEDATE]<'" + endDate.ToString("yyyy-MM-dd") + @"'  
	                       and [DEVICEID] in('0002','0004','0006','0008')
	                       group by datepart(HH,RECEIVEDATE),datepart(mi,RECEIVEDATE)/15
	                       order by datepart(HH,RECEIVEDATE),datepart(mi,RECEIVEDATE)/15";

            var tempResult1 = DB.ExecuteQuery<eTagAllFlow>(sql);

            string sql2 = @"SELECT datepart(HH,RECEIVEDATE) Hour,datepart(mi,RECEIVEDATE)/15 Minute,
                        count(*) Nums
                        FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                        where [RECEIVEDATE]>'" + startDate.ToString("yyyy-MM-dd") + @"'
                        and [RECEIVEDATE]<'" + endDate.ToString("yyyy-MM-dd") + @"'  
                        and substring(PLATEID,6,1)!='3'
                        and [DEVICEID] in('0002','0004','0006','0008')
                        group by datepart(HH,RECEIVEDATE),datepart(mi,RECEIVEDATE)/15
                        order by datepart(HH,RECEIVEDATE),datepart(mi,RECEIVEDATE)/15";

            var tempResult2 = DB.ExecuteQuery<eTagAllFlow>(sql2);
            var tempJoinResult1 = from a in tempResult1
                                  join b in tempResult2
                                  on new { Hour = a.Hour, Minute = a.Minute }
                                  equals
                                  new { b.Hour, b.Minute } into subGrp
                                  from b in subGrp.DefaultIfEmpty()
                                  select new
                                  {
                                      a.Minute,
                                      a.Hour,
                                      AllNums = a.Nums,
                                      BNums = (b == null ? 0 : b.Nums)
                                  };
            string sql3 = @"SELECT datepart(HH,RECEIVEDATE) Hour,datepart(mi,RECEIVEDATE)/15 Minute,
                        count(*) Nums
                        FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                        where [RECEIVEDATE]>'" + startDate.ToString("yyyy-MM-dd") + @"'
                        and [RECEIVEDATE]<'" + endDate.ToString("yyyy-MM-dd") + @"'  
                        and [DEVICEID] in('0001','0003','0005','0007')
                        group by datepart(HH,RECEIVEDATE),datepart(mi,RECEIVEDATE)/15
                        order by datepart(HH,RECEIVEDATE),datepart(mi,RECEIVEDATE)/15";

            var tempResult3 = DB.ExecuteQuery<eTagAllFlow>(sql3);

            string sql4 = @"SELECT datepart(HH,RECEIVEDATE) Hour,datepart(mi,RECEIVEDATE)/15 Minute,
                        count(*) Nums
                        FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                        where [RECEIVEDATE]>'" + startDate.ToString("yyyy-MM-dd") + @"'
                        and [RECEIVEDATE]<'" + endDate.ToString("yyyy-MM-dd") + @"'  
                        and substring(PLATEID,6,1)!='3'
                        and [DEVICEID] in('0001','0003','0005','0007')
                        group by datepart(HH,RECEIVEDATE),datepart(mi,RECEIVEDATE)/15
                        order by datepart(HH,RECEIVEDATE),datepart(mi,RECEIVEDATE)/15";

            var tempResult4 = DB.ExecuteQuery<eTagAllFlow>(sql4);
            var tempJoinResult2 = from a in tempResult3
                                  join b in tempResult4
                                  on new { Hour = a.Hour, Minute = a.Minute }
                                  equals
                                  new { b.Hour, b.Minute } into subGrp
                                  from b in subGrp.DefaultIfEmpty()
                                  select new
                                  {
                                      a.Minute,
                                      a.Hour,
                                      AllNums = a.Nums,
                                      BNums = (b == null ? 0 : b.Nums)
                                  };
            var tempJoinResult = from a in tempJoinResult1
                                 join b in tempJoinResult2
                                 on new { Hour = a.Hour, Minute = a.Minute }
                                 equals
                                 new { b.Hour, b.Minute } into subGrp
                                 from b in subGrp.DefaultIfEmpty()
                                 select new
                                 {
                                     a.Minute,
                                     a.Hour,
                                     ComeAllNums = a.AllNums,
                                     ComeBNums = a.BNums,
                                     ComeSNums = a.AllNums - a.BNums,
                                     LeaveAllNums = (b == null ? 0 : b.AllNums),
                                     LeaveBNums = (b == null ? 0 : b.BNums),
                                     LeaveSNums = (b == null ? 0 : b.AllNums) - (b == null ? 0 : b.BNums),
                                 };





            TimeFlowTable hourFlow = new TimeFlowTable("1");
            TimeFlowTable minuteFlow = new TimeFlowTable("2");
            foreach (var temp in tempJoinResult)
            {

                int i = temp.Hour;
                int j = temp.Minute;

                hourFlow[i].ComeAllNums = hourFlow[i].ComeAllNums + temp.ComeAllNums;
                hourFlow[i].ComeBNums = hourFlow[i].ComeBNums + temp.ComeBNums;
                hourFlow[i].ComeSNums = hourFlow[i].ComeSNums + temp.ComeSNums;
                hourFlow[i].LeaveAllNums = hourFlow[i].LeaveAllNums + temp.LeaveAllNums;
                hourFlow[i].LeaveBNums = hourFlow[i].LeaveBNums + temp.LeaveBNums;
                hourFlow[i].LeaveSNums = hourFlow[i].LeaveSNums + temp.LeaveSNums;

                minuteFlow[(i * 4) + j].ComeAllNums = temp.ComeAllNums;
                minuteFlow[(i * 4) + j].ComeBNums = temp.ComeBNums;
                minuteFlow[(i * 4) + j].ComeSNums = temp.ComeSNums;
                minuteFlow[(i * 4) + j].LeaveAllNums = temp.LeaveAllNums;
                minuteFlow[(i * 4) + j].LeaveBNums = temp.LeaveBNums;
                minuteFlow[(i * 4) + j].LeaveSNums = temp.LeaveSNums;
            }

            //晨峰7-9
            hourFlow[24].ComeAllNums = ((hourFlow[7].ComeAllNums + hourFlow[8].ComeAllNums) / 2);
            hourFlow[24].ComeBNums = ((hourFlow[7].ComeBNums + hourFlow[8].ComeBNums) / 2);
            hourFlow[24].ComeSNums = ((hourFlow[7].ComeSNums + hourFlow[8].ComeSNums) / 2);
            hourFlow[24].LeaveAllNums = ((hourFlow[7].LeaveAllNums + hourFlow[8].LeaveAllNums) / 2);
            hourFlow[24].LeaveBNums = ((hourFlow[7].LeaveBNums + hourFlow[8].LeaveBNums) / 2);
            hourFlow[24].LeaveSNums = ((hourFlow[7].LeaveSNums + hourFlow[8].LeaveSNums) / 2);
            //////昏峰17-19
            ////timeFlowNum[25].twoNum = (timeFlowNum[17].twoNum + timeFlowNum[18].twoNum) / 2;
            ////timeFlowNum[25].oneNum = (timeFlowNum[17].oneNum + timeFlowNum[18].oneNum) / 2;
            ////timeFlowNum[25].bTwoNum = (timeFlowNum[17].bTwoNum + timeFlowNum[18].bTwoNum) / 2;
            ////timeFlowNum[25].sTwoNum = (timeFlowNum[17].sTwoNum + timeFlowNum[18].sTwoNum) / 2;
            ////timeFlowNum[25].sOneNum = (timeFlowNum[17].sOneNum + timeFlowNum[18].sOneNum) / 2;
            ////timeFlowNum[25].bOneNum = (timeFlowNum[17].bOneNum + timeFlowNum[18].bOneNum) / 2;
            //////離峰9-17
            ////for (int i = 9; i < 17; i++)
            ////{
            ////    timeFlowNum[26].twoNum = timeFlowNum[26].twoNum + timeFlowNum[i].twoNum;
            ////}
            ////timeFlowNum[26].twoNum = timeFlowNum[26].twoNum / 8;

            ////for (int i = 9; i < 17; i++)
            ////{
            ////    timeFlowNum[26].oneNum = timeFlowNum[26].oneNum + timeFlowNum[i].oneNum;
            ////}
            ////timeFlowNum[26].oneNum = timeFlowNum[26].oneNum / 8;

            ////for (int i = 9; i < 17; i++)
            ////{
            ////    timeFlowNum[26].bTwoNum = timeFlowNum[26].bTwoNum + timeFlowNum[i].bTwoNum;
            ////}
            ////timeFlowNum[26].bTwoNum = timeFlowNum[26].bTwoNum / 8;

            ////for (int i = 9; i < 17; i++)
            ////{
            ////    timeFlowNum[26].sTwoNum = timeFlowNum[26].sTwoNum + timeFlowNum[i].sTwoNum;
            ////}
            ////timeFlowNum[26].sTwoNum = timeFlowNum[26].sTwoNum / 8;

            ////for (int i = 9; i < 17; i++)
            ////{
            ////    timeFlowNum[26].sOneNum = timeFlowNum[26].sOneNum + timeFlowNum[i].sOneNum;
            ////}
            ////timeFlowNum[26].sOneNum = timeFlowNum[26].sOneNum / 8;

            ////for (int i = 9; i < 17; i++)
            ////{
            ////    timeFlowNum[26].bOneNum = timeFlowNum[26].bOneNum + timeFlowNum[i].bOneNum;
            ////}
            ////timeFlowNum[26].bOneNum = timeFlowNum[26].bOneNum / 8;

            //////全日
            ////for (int i = 0; i < 24; i++)
            ////{
            ////    timeFlowNum[27].twoNum = timeFlowNum[27].twoNum + timeFlowNum[i].twoNum;
            ////}
            ////timeFlowNum[27].twoNum = timeFlowNum[27].twoNum / 24;

            ////for (int i = 0; i < 24; i++)
            ////{
            ////    timeFlowNum[27].oneNum = timeFlowNum[27].oneNum + timeFlowNum[i].oneNum;
            ////}
            ////timeFlowNum[27].oneNum = timeFlowNum[27].oneNum / 24;

            ////for (int i = 0; i < 24; i++)
            ////{
            ////    timeFlowNum[27].bTwoNum = timeFlowNum[27].bTwoNum + timeFlowNum[i].bTwoNum;
            ////}
            ////timeFlowNum[27].bTwoNum = timeFlowNum[27].bTwoNum / 24;

            ////for (int i = 0; i < 24; i++)
            ////{
            ////    timeFlowNum[27].sTwoNum = timeFlowNum[27].sTwoNum + timeFlowNum[i].sTwoNum;
            ////}
            ////timeFlowNum[27].sTwoNum = timeFlowNum[27].sTwoNum / 24;

            ////for (int i = 0; i < 24; i++)
            ////{
            ////    timeFlowNum[27].sOneNum = timeFlowNum[27].sOneNum + timeFlowNum[i].sOneNum;
            ////}
            ////timeFlowNum[27].sOneNum = timeFlowNum[27].sOneNum / 24;

            ////for (int i = 0; i < 24; i++)
            ////{
            ////    timeFlowNum[27].bOneNum = timeFlowNum[27].bOneNum + timeFlowNum[i].bOneNum;
            ////}
            ////timeFlowNum[27].bOneNum = timeFlowNum[27].bOneNum / 24;
            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("HourFlow", hourFlow);
            result.Add("MinuteFlow", minuteFlow);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
    }

    public string yearTr(string a)
    {
        if (a == null)
        {
            return "";
        }
        else
        {
            DateTime s = DateTime.Parse(a);
            return string.Format("{0}-{1:MM-dd}", s.Year - 1911, s);
        }
    }

    public int ttt(dynamic a)
    {
        return 0;
    }
    public string ETagBaseDataTr(dynamic a)
    {
        string c = a + "";
        int year = Int32.Parse(c.Split('-')[0]) + 1911;
        DateTime date = DateTime.Parse(year + "-" + c.Split('-')[1] + "-" + c.Split('-')[2]);
        return date.ToString("yyyy-MM-dd");
    }
    public string getChangeDate(dynamic a)
    {
        string c = a + "";
        int year = Int32.Parse(c.Split('-')[0]) + 1911;
        DateTime date = DateTime.Parse(year + "-" + c.Split('-')[1] + "-" + c.Split('-')[2]);
        return date.ToString("yyyyMMdd");
    }
    public string getChangeDate2(dynamic a)
    {
        string c = a + "";
        int year = Int32.Parse(c.Split('-')[0]) + 1911;
        DateTime date = DateTime.Parse(year + "-" + c.Split('-')[1] + "-" + c.Split('-')[2]);
        return date.AddDays(1).ToString("yyyyMMdd");
    }
    public DateTime startDateTr(dynamic a)
    {
        string c = a + "";
        int year = Int32.Parse(c.Split('-')[0]) + 1911;
        DateTime date = DateTime.Parse(year + "-" + c.Split('-')[1] + "-" + c.Split('-')[2]);
        return date;
    }
    public DateTime endDateTr(dynamic a)
    {
        string c = a + "";
        int year = Int32.Parse(c.Split('-')[0]) + 1911;
        DateTime date = DateTime.Parse(year + "-" + c.Split('-')[1] + "-" + c.Split('-')[2]);
        return date.AddMinutes(1);
    }
    public DateTime endDateTr2(dynamic a)
    {
        string c = a + "";
        int year = Int32.Parse(c.Split('-')[0]) + 1911;
        DateTime date = DateTime.Parse(year + "-" + c.Split('-')[1] + "-" + c.Split('-')[2]);
        return date.AddDays(1);
    }
    public string hourColText(string hour)
    {
        string toHour = (Int32.Parse(hour) + 1).ToString();
        if (toHour.Length == 1)
        {
            toHour = "0" + toHour;
        }
        return hour + ":00 - " + toHour + ":00";
    }
    public class aaa
    {
        public string DayOfWeek;
        public string Hour;
        public int Nums;
    }

    public class timeFlow
    {
        public timeFlow(string a)
        {
            this.hour = a;
            this.oneNum = 0;
            this.twoNum = 0;
            this.sOneNum = 0;
            this.sTwoNum = 0;
            this.bOneNum = 0;
            this.bTwoNum = 0;
        }
        public timeFlow()
        {
            this.oneNum = 0;
            this.twoNum = 0;
            this.sOneNum = 0;
            this.sTwoNum = 0;
            this.bOneNum = 0;
            this.bTwoNum = 0;
        }
        public string hour;
        public float oneNum;
        public float twoNum;
        public float sOneNum;
        public float sTwoNum;
        public float bOneNum;
        public float bTwoNum;

    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}