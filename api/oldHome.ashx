<%@ WebHandler Language="C#" Class="eTagWeekTimeFlow" %>

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

public class eTagWeekTimeFlow : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        DataClasses3DataContext DB = new DataClasses3DataContext();
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
        else if (type.Equals("週內日進出入統計"))
        {
            dynamic json = JValue.Parse(str);
            string tempDate = json.startDate;
            string tempDate2 = json.endDate;
            string startDate = DateProcess.民國年轉西元年回傳字串格式(tempDate);
            string endDate = DateProcess.民國年轉西元年回傳字串格式(tempDate2, 1);
            DateTime startDateD = DateProcess.民國年轉西元年回傳日期格式(tempDate);
            DateTime endDateD = DateProcess.民國年轉西元年回傳日期格式(tempDate2, 1);

            //哈馬星進1001,1003,1008
            //哈馬星出1002,1004,1007             


            string sql = @"select c.kk 星期,avg(c.aa) 進入
                           from(
                           SELECT DatePart(WeekDay,RECEIVEDATE) kk,CONVERT(varchar(100),RECEIVEDATE, 112) aas,count(*) aa
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + startDate + @"' and RECEIVEDATE<'" + endDate + @"'
                           and (DEVICEID='1001' or DEVICEID='1003' or DEVICEID='1008')
                           group by CONVERT(varchar(100),RECEIVEDATE, 112),DatePart(WeekDay,RECEIVEDATE))c
                           group by c.kk";
            string sql2 = @"select c.kk 星期,avg(c.aa) 離開
                           from(
                           SELECT DatePart(WeekDay,RECEIVEDATE) kk,CONVERT(varchar(100),RECEIVEDATE, 112) aas,count(*) aa
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + startDate + @"' and RECEIVEDATE<'" + endDate + @"'
                           and (DEVICEID='1002' or DEVICEID='1004' or DEVICEID='1007')
                           group by CONVERT(varchar(100),RECEIVEDATE, 112),DatePart(WeekDay,RECEIVEDATE))c
                           group by c.kk";



            var temp = DB.ExecuteQuery<進入統計>(sql).ToList();
            var temp2 = DB.ExecuteQuery<離開統計>(sql2).ToList();

            List<滯留統計> temp3 = new List<滯留統計>();
            for (int i = 0; i < temp.Count; i++)
            {
                滯留統計 tt = new 滯留統計();
                tt.滯留 = temp[i].進入 - temp2[i].離開 - 700;
                temp3.Add(tt);
            }

            Dictionary<string, dynamic> temp_1 = new Dictionary<string, dynamic>();
            temp_1.Add("ComeNum", temp);
            temp_1.Add("LeaveNum", temp2);
            temp_1.Add("StopNum", temp3);

            //西子灣進1007
            //西子灣出1008
             string sql3 = @"select c.kk 星期,avg(c.aa) 進入
                           from(
                           SELECT DatePart(WeekDay,RECEIVEDATE) kk,CONVERT(varchar(100),RECEIVEDATE, 112) aas,count(*) aa
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + startDate + @"' and RECEIVEDATE<'" + endDate + @"'
                           and (DEVICEID='1004')
                           group by CONVERT(varchar(100),RECEIVEDATE, 112),DatePart(WeekDay,RECEIVEDATE))c
                           group by c.kk";
            string sql4 = @"select c.kk 星期,avg(c.aa) 離開
                           from(
                           SELECT DatePart(WeekDay,RECEIVEDATE) kk,CONVERT(varchar(100),RECEIVEDATE, 112) aas,count(*) aa
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>='" + startDate + @"' and RECEIVEDATE<'" + endDate + @"'
                           and (DEVICEID='1008')
                           group by CONVERT(varchar(100),RECEIVEDATE, 112),DatePart(WeekDay,RECEIVEDATE))c
                           group by c.kk";



            var temp4 = DB.ExecuteQuery<進入統計>(sql3).ToList();
            var temp5 = DB.ExecuteQuery<離開統計>(sql4).ToList();

            List<滯留統計> temp6 = new List<滯留統計>();
            for (int i = 0; i < temp.Count; i++)
            {
                滯留統計 tt = new 滯留統計();
                tt.滯留 = temp[i].進入 - temp2[i].離開 - 700;
                temp6.Add(tt);
            }

            Dictionary<string, dynamic> temp_2 = new Dictionary<string, dynamic>();
            temp_2.Add("ComeNum", temp4);
            temp_2.Add("LeaveNum", temp5);
            temp_2.Add("StopNum", temp6);


            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("One", temp_1);
            result.Add("Two", temp_2);

            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("週內日分時流量資料"))
        {
            dynamic json = JValue.Parse(str);
            string tempDate = json.startDate;
            string tempDate2 = json.endDate;
            string startDate = DateProcess.民國年轉西元年回傳字串格式(tempDate);
            string endDate = DateProcess.民國年轉西元年回傳字串格式(tempDate2, 1);
            DateTime startDateD = DateProcess.民國年轉西元年回傳日期格式(tempDate);
            DateTime endDateD = DateProcess.民國年轉西元年回傳日期格式(tempDate2, 1);
            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();

            //1代表不要先設定分頁名稱
            ExcelCreate Excel = new ExcelCreate("1");
            List<string> tempTitle = new List<string>();

            地區週內日分時流量報表 報表 = new 地區週內日分時流量報表();

            string sql = @"select c.小時,c.週內日,avg(c.aa) 數量
                                       from (
                                       SELECT CONVERT(varchar(100),RECEIVEDATE, 112) 日期,
                                       DatePart(WeekDay,RECEIVEDATE) 週內日,
                                       datepart(hh,RECEIVEDATE) 小時,
                                       count(*) aa
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                                       where [RECEIVEDATE]>='" + startDate + @"'
                                       and [RECEIVEDATE]<'" + endDate + @"'
                                       and ([DEVICEID]='1001' or [DEVICEID]='1003' or [DEVICEID]='1008')";
            //foreach (var notDateListTemp in json.notDateList)
            //{
            //    string ttTemp = DateProcess.民國年轉西元年回傳字串格式(notDateListTemp.date);
            //    sql = sql + @"and CONVERT(varchar(100), [RECEIVEDATE], 112)!='" + ttTemp + "'";
            //}
            sql = sql + @"group by CONVERT(varchar(100),RECEIVEDATE, 112),
                          DatePart(WeekDay,RECEIVEDATE),datepart(hh,RECEIVEDATE))c
                          group by 週內日,c.小時";
            List<bool> 有沒有該星期判斷 = new List<bool>();
            for (int i = 0; i < 8; i++)
            {
                有沒有該星期判斷.Add(false);
            }

            var 地區週內日分時流量進入 = DB.ExecuteQuery<地區週內日分時流量>(sql);
            foreach (var temp in 地區週內日分時流量進入)
            {
                if (temp.週內日 == 1)
                {
                    報表.星期日[temp.小時].ComeHour = temp.數量;
                    有沒有該星期判斷[1] = true;
                }
                else if (temp.週內日 == 2)
                {
                    報表.星期一[temp.小時].ComeHour = temp.數量;
                    有沒有該星期判斷[2] = true;
                }
                else if (temp.週內日 == 3)
                {
                    報表.星期二[temp.小時].ComeHour = temp.數量;
                    有沒有該星期判斷[3] = true;
                }
                else if (temp.週內日 == 4)
                {
                    報表.星期三[temp.小時].ComeHour = temp.數量;
                    有沒有該星期判斷[4] = true;
                }
                else if (temp.週內日 == 5)
                {
                    報表.星期四[temp.小時].ComeHour = temp.數量;
                    有沒有該星期判斷[5] = true;
                }
                else if (temp.週內日 == 6)
                {
                    報表.星期五[temp.小時].ComeHour = temp.數量;
                    有沒有該星期判斷[6] = true;
                }
                else if (temp.週內日 == 7)
                {
                    報表.星期六[temp.小時].ComeHour = temp.數量;
                    有沒有該星期判斷[7] = true;
                }
            }
            sql = @"select c.小時,c.週內日,avg(c.aa) 數量
                                       from (
                                       SELECT CONVERT(varchar(100),RECEIVEDATE, 112) 日期,
                                       DatePart(WeekDay,RECEIVEDATE) 週內日,
                                       datepart(hh,RECEIVEDATE) 小時,
                                       count(*) aa
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                                       where [RECEIVEDATE]>='" + startDate + @"'
                                       and [RECEIVEDATE]<'" + endDate + @"'
                                       and ([DEVICEID]='1002' or [DEVICEID]='1004' or [DEVICEID]='1007')";
            //foreach (var notDateListTemp in json.notDateList)
            //{
            //    string ttTemp = DateProcess.民國年轉西元年回傳字串格式(notDateListTemp.date);
            //    sql = sql + @"and CONVERT(varchar(100), [RECEIVEDATE], 112)!='" + ttTemp + "'";
            //}
            sql = sql + @"group by CONVERT(varchar(100),RECEIVEDATE, 112),
                                      DatePart(WeekDay,RECEIVEDATE),datepart(hh,RECEIVEDATE))c
                                      group by 週內日,c.小時";

            var 地區週內日分時流量離開 = DB.ExecuteQuery<地區週內日分時流量>(sql);
            foreach (var temp in 地區週內日分時流量離開)
            {
                if (temp.週內日 == 1)
                {
                    報表.星期日[temp.小時].LeaveHour = temp.數量;
                    有沒有該星期判斷[1] = true;
                }
                else if (temp.週內日 == 2)
                {
                    報表.星期一[temp.小時].LeaveHour = temp.數量;
                    有沒有該星期判斷[2] = true;
                }
                else if (temp.週內日 == 3)
                {
                    報表.星期二[temp.小時].LeaveHour = temp.數量;
                    有沒有該星期判斷[3] = true;
                }
                else if (temp.週內日 == 4)
                {
                    報表.星期三[temp.小時].LeaveHour = temp.數量;
                    有沒有該星期判斷[4] = true;
                }
                else if (temp.週內日 == 5)
                {
                    報表.星期四[temp.小時].LeaveHour = temp.數量;
                    有沒有該星期判斷[5] = true;
                }
                else if (temp.週內日 == 6)
                {
                    報表.星期五[temp.小時].LeaveHour = temp.數量;
                    有沒有該星期判斷[6] = true;
                }
                else if (temp.週內日 == 7)
                {
                    報表.星期六[temp.小時].LeaveHour = temp.數量;
                    有沒有該星期判斷[7] = true;
                }
            }

            計算滯留(報表, 700);
            計算進入累積(報表);
            計算離開累積(報表);
            計算滯留累積(報表);

            地區週內日分時流量報表 報表2 = new 地區週內日分時流量報表();

            sql = @"select c.小時,c.週內日,avg(c.aa) 數量
                                       from (
                                       SELECT CONVERT(varchar(100),RECEIVEDATE, 112) 日期,
                                       DatePart(WeekDay,RECEIVEDATE) 週內日,
                                       datepart(hh,RECEIVEDATE) 小時,
                                       count(*) aa
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                                       where [RECEIVEDATE]>='" + startDate + @"'
                                       and [RECEIVEDATE]<'" + endDate + @"'
                                       and ([DEVICEID]='1007')";
            //foreach (var notDateListTemp in json.notDateList)
            //{
            //    string ttTemp = DateProcess.民國年轉西元年回傳字串格式(notDateListTemp.date);
            //    sql = sql + @"and CONVERT(varchar(100), [RECEIVEDATE], 112)!='" + ttTemp + "'";
            //}
            sql = sql + @"group by CONVERT(varchar(100),RECEIVEDATE, 112),
                          DatePart(WeekDay,RECEIVEDATE),datepart(hh,RECEIVEDATE))c
                          group by 週內日,c.小時";

            var 地區週內日分時流量進入2 = DB.ExecuteQuery<地區週內日分時流量>(sql);
            foreach (var temp in 地區週內日分時流量進入2)
            {
                if (temp.週內日 == 1)
                {
                    報表2.星期日[temp.小時].ComeHour = temp.數量;
                    有沒有該星期判斷[1] = true;
                }
                else if (temp.週內日 == 2)
                {
                    報表2.星期一[temp.小時].ComeHour = temp.數量;
                    有沒有該星期判斷[2] = true;
                }
                else if (temp.週內日 == 3)
                {
                    報表2.星期二[temp.小時].ComeHour = temp.數量;
                    有沒有該星期判斷[3] = true;
                }
                else if (temp.週內日 == 4)
                {
                    報表2.星期三[temp.小時].ComeHour = temp.數量;
                    有沒有該星期判斷[4] = true;
                }
                else if (temp.週內日 == 5)
                {
                    報表2.星期四[temp.小時].ComeHour = temp.數量;
                    有沒有該星期判斷[5] = true;
                }
                else if (temp.週內日 == 6)
                {
                    報表2.星期五[temp.小時].ComeHour = temp.數量;
                    有沒有該星期判斷[6] = true;
                }
                else if (temp.週內日 == 7)
                {
                    報表2.星期六[temp.小時].ComeHour = temp.數量;
                    有沒有該星期判斷[7] = true;
                }
            }
            sql = @"select c.小時,c.週內日,avg(c.aa) 數量
                                       from (
                                       SELECT CONVERT(varchar(100),RECEIVEDATE, 112) 日期,
                                       DatePart(WeekDay,RECEIVEDATE) 週內日,
                                       datepart(hh,RECEIVEDATE) 小時,
                                       count(*) aa
                                       FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                                       where [RECEIVEDATE]>='" + startDate + @"'
                                       and [RECEIVEDATE]<'" + endDate + @"'
                                       and ([DEVICEID]='1008')";
            //foreach (var notDateListTemp in json.notDateList)
            //{
            //    string ttTemp = DateProcess.民國年轉西元年回傳字串格式(notDateListTemp.date);
            //    sql = sql + @"and CONVERT(varchar(100), [RECEIVEDATE], 112)!='" + ttTemp + "'";
            //}
            sql = sql + @"group by CONVERT(varchar(100),RECEIVEDATE, 112),
                                      DatePart(WeekDay,RECEIVEDATE),datepart(hh,RECEIVEDATE))c
                                      group by 週內日,c.小時";

            var 地區週內日分時流量離開2 = DB.ExecuteQuery<地區週內日分時流量>(sql);
            foreach (var temp in 地區週內日分時流量離開2)
            {
                if (temp.週內日 == 1)
                {
                    報表2.星期日[temp.小時].LeaveHour = temp.數量;
                    有沒有該星期判斷[1] = true;
                }
                else if (temp.週內日 == 2)
                {
                    報表2.星期一[temp.小時].LeaveHour = temp.數量;
                    有沒有該星期判斷[2] = true;
                }
                else if (temp.週內日 == 3)
                {
                    報表2.星期二[temp.小時].LeaveHour = temp.數量;
                    有沒有該星期判斷[3] = true;
                }
                else if (temp.週內日 == 4)
                {
                    報表2.星期三[temp.小時].LeaveHour = temp.數量;
                    有沒有該星期判斷[4] = true;
                }
                else if (temp.週內日 == 5)
                {
                    報表2.星期四[temp.小時].LeaveHour = temp.數量;
                    有沒有該星期判斷[5] = true;
                }
                else if (temp.週內日 == 6)
                {
                    報表2.星期五[temp.小時].LeaveHour = temp.數量;
                    有沒有該星期判斷[6] = true;
                }
                else if (temp.週內日 == 7)
                {
                    報表2.星期六[temp.小時].LeaveHour = temp.數量;
                    有沒有該星期判斷[7] = true;
                }
            }

            計算滯留(報表2, 0);
            計算進入累積(報表2);
            計算離開累積(報表2);
            計算滯留累積(報表2);
            string exceldate = tempDate + " ~ " + tempDate2;
            if (tempDate == tempDate2)
            {
                exceldate = tempDate;
            }
            if (有沒有該星期判斷[1])
            {
                Excel.sheetCreate("週日");
                Excel.設定歷史分時流量報表標題(exceldate, "週日");
                for (int y = 0; y < 25; y++)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(報表.星期日[y].Hour);
                    textTemp.Add(報表.星期日[y].ComeHour);
                    textTemp.Add(報表.星期日[y].Come);
                    textTemp.Add(報表.星期日[y].LeaveHour);
                    textTemp.Add(報表.星期日[y].Leave);
                    textTemp.Add(報表.星期日[y].StopHour);
                    textTemp.Add(報表.星期日[y].Stop);
                    textTemp.Add(報表2.星期日[y].ComeHour);
                    textTemp.Add(報表2.星期日[y].Come);
                    textTemp.Add(報表2.星期日[y].LeaveHour);
                    textTemp.Add(報表2.星期日[y].Leave);
                    textTemp.Add(報表2.星期日[y].StopHour);
                    textTemp.Add(報表2.星期日[y].Stop);
                    Excel.分時流量新增(textTemp);
                }
                Excel.換sheet();
            }
            if (有沒有該星期判斷[2])
            {
                Excel.sheetCreate("週一");
                Excel.設定歷史分時流量報表標題(exceldate, "週一");
                for (int y = 0; y < 25; y++)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(報表.星期一[y].Hour);
                    textTemp.Add(報表.星期一[y].ComeHour);
                    textTemp.Add(報表.星期一[y].Come);
                    textTemp.Add(報表.星期一[y].LeaveHour);
                    textTemp.Add(報表.星期一[y].Leave);
                    textTemp.Add(報表.星期一[y].StopHour);
                    textTemp.Add(報表.星期一[y].Stop);
                    textTemp.Add(報表2.星期一[y].ComeHour);
                    textTemp.Add(報表2.星期一[y].Come);
                    textTemp.Add(報表2.星期一[y].LeaveHour);
                    textTemp.Add(報表2.星期一[y].Leave);
                    textTemp.Add(報表2.星期一[y].StopHour);
                    textTemp.Add(報表2.星期一[y].Stop);
                    Excel.分時流量新增(textTemp);
                }
                Excel.換sheet();
            }

            if (有沒有該星期判斷[3])
            {
                Excel.sheetCreate("週二");
                Excel.設定歷史分時流量報表標題(exceldate, "週二");
                for (int y = 0; y < 25; y++)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(報表.星期二[y].Hour);
                    textTemp.Add(報表.星期二[y].ComeHour);
                    textTemp.Add(報表.星期二[y].Come);
                    textTemp.Add(報表.星期二[y].LeaveHour);
                    textTemp.Add(報表.星期二[y].Leave);
                    textTemp.Add(報表.星期二[y].StopHour);
                    textTemp.Add(報表.星期二[y].Stop);
                    textTemp.Add(報表2.星期二[y].ComeHour);
                    textTemp.Add(報表2.星期二[y].Come);
                    textTemp.Add(報表2.星期二[y].LeaveHour);
                    textTemp.Add(報表2.星期二[y].Leave);
                    textTemp.Add(報表2.星期二[y].StopHour);
                    textTemp.Add(報表2.星期二[y].Stop);
                    Excel.分時流量新增(textTemp);
                }
                Excel.換sheet();
            }
            if (有沒有該星期判斷[4])
            {
                Excel.sheetCreate("週三");
                Excel.設定歷史分時流量報表標題(exceldate, "週三");
                for (int y = 0; y < 25; y++)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(報表.星期三[y].Hour);
                    textTemp.Add(報表.星期三[y].ComeHour);
                    textTemp.Add(報表.星期三[y].Come);
                    textTemp.Add(報表.星期三[y].LeaveHour);
                    textTemp.Add(報表.星期三[y].Leave);
                    textTemp.Add(報表.星期三[y].StopHour);
                    textTemp.Add(報表.星期三[y].Stop);
                    textTemp.Add(報表2.星期三[y].ComeHour);
                    textTemp.Add(報表2.星期三[y].Come);
                    textTemp.Add(報表2.星期三[y].LeaveHour);
                    textTemp.Add(報表2.星期三[y].Leave);
                    textTemp.Add(報表2.星期三[y].StopHour);
                    textTemp.Add(報表2.星期三[y].Stop);
                    Excel.分時流量新增(textTemp);
                }
                Excel.換sheet();
            }
            if (有沒有該星期判斷[5])
            {
                Excel.sheetCreate("週四");
                Excel.設定歷史分時流量報表標題(exceldate, "週四");
                for (int y = 0; y < 25; y++)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(報表.星期四[y].Hour);
                    textTemp.Add(報表.星期四[y].ComeHour);
                    textTemp.Add(報表.星期四[y].Come);
                    textTemp.Add(報表.星期四[y].LeaveHour);
                    textTemp.Add(報表.星期四[y].Leave);
                    textTemp.Add(報表.星期四[y].StopHour);
                    textTemp.Add(報表.星期四[y].Stop);
                    textTemp.Add(報表2.星期四[y].ComeHour);
                    textTemp.Add(報表2.星期四[y].Come);
                    textTemp.Add(報表2.星期四[y].LeaveHour);
                    textTemp.Add(報表2.星期四[y].Leave);
                    textTemp.Add(報表2.星期四[y].StopHour);
                    textTemp.Add(報表2.星期四[y].Stop);
                    Excel.分時流量新增(textTemp);
                }
                Excel.換sheet();
            }
            if (有沒有該星期判斷[6])
            {
                Excel.sheetCreate("週五");
                Excel.設定歷史分時流量報表標題(exceldate, "週五");
                for (int y = 0; y < 25; y++)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(報表.星期五[y].Hour);
                    textTemp.Add(報表.星期五[y].ComeHour);
                    textTemp.Add(報表.星期五[y].Come);
                    textTemp.Add(報表.星期五[y].LeaveHour);
                    textTemp.Add(報表.星期五[y].Leave);
                    textTemp.Add(報表.星期五[y].StopHour);
                    textTemp.Add(報表.星期五[y].Stop);
                    textTemp.Add(報表2.星期五[y].ComeHour);
                    textTemp.Add(報表2.星期五[y].Come);
                    textTemp.Add(報表2.星期五[y].LeaveHour);
                    textTemp.Add(報表2.星期五[y].Leave);
                    textTemp.Add(報表2.星期五[y].StopHour);
                    textTemp.Add(報表2.星期五[y].Stop);
                    Excel.分時流量新增(textTemp);
                }
                Excel.換sheet();
            }
            if (有沒有該星期判斷[7])
            {
                Excel.sheetCreate("週六");
                Excel.設定歷史分時流量報表標題(exceldate, "週六");
                for (int y = 0; y < 25; y++)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(報表.星期六[y].Hour);
                    textTemp.Add(報表.星期六[y].ComeHour);
                    textTemp.Add(報表.星期六[y].Come);
                    textTemp.Add(報表.星期六[y].LeaveHour);
                    textTemp.Add(報表.星期六[y].Leave);
                    textTemp.Add(報表.星期六[y].StopHour);
                    textTemp.Add(報表.星期六[y].Stop);
                    textTemp.Add(報表2.星期六[y].ComeHour);
                    textTemp.Add(報表2.星期六[y].Come);
                    textTemp.Add(報表2.星期六[y].LeaveHour);
                    textTemp.Add(報表2.星期六[y].Leave);
                    textTemp.Add(報表2.星期六[y].StopHour);
                    textTemp.Add(報表2.星期六[y].Stop);
                    Excel.分時流量新增(textTemp);
                }
                Excel.換sheet();
            }

            Excel.excelOutput(context.Request, "哈瑪星及西子灣進出累計車流輛");



            List<dynamic> HamaxingCount = new List<dynamic>();
            HamaxingCount.Add(回傳整理好的累積統計(報表.星期日, 有沒有該星期判斷[1]));
            HamaxingCount.Add(回傳整理好的累積統計(報表.星期一, 有沒有該星期判斷[2]));
            HamaxingCount.Add(回傳整理好的累積統計(報表.星期二, 有沒有該星期判斷[3]));
            HamaxingCount.Add(回傳整理好的累積統計(報表.星期三, 有沒有該星期判斷[4]));
            HamaxingCount.Add(回傳整理好的累積統計(報表.星期四, 有沒有該星期判斷[5]));
            HamaxingCount.Add(回傳整理好的累積統計(報表.星期五, 有沒有該星期判斷[6]));
            HamaxingCount.Add(回傳整理好的累積統計(報表.星期六, 有沒有該星期判斷[7]));

            List<dynamic> HamaxingHourCount = new List<dynamic>();
            HamaxingHourCount.Add(回傳整理好的分時統計(報表.星期日, 有沒有該星期判斷[1]));
            HamaxingHourCount.Add(回傳整理好的分時統計(報表.星期一, 有沒有該星期判斷[2]));
            HamaxingHourCount.Add(回傳整理好的分時統計(報表.星期二, 有沒有該星期判斷[3]));
            HamaxingHourCount.Add(回傳整理好的分時統計(報表.星期三, 有沒有該星期判斷[4]));
            HamaxingHourCount.Add(回傳整理好的分時統計(報表.星期四, 有沒有該星期判斷[5]));
            HamaxingHourCount.Add(回傳整理好的分時統計(報表.星期五, 有沒有該星期判斷[6]));
            HamaxingHourCount.Add(回傳整理好的分時統計(報表.星期六, 有沒有該星期判斷[7]));

            result.Add("HamaxingCount", HamaxingCount);
            result.Add("HamaxingHourCount", HamaxingHourCount);

            List<dynamic> SiziwanCount = new List<dynamic>();
            SiziwanCount.Add(回傳整理好的累積統計(報表2.星期日, 有沒有該星期判斷[1]));
            SiziwanCount.Add(回傳整理好的累積統計(報表2.星期一, 有沒有該星期判斷[2]));
            SiziwanCount.Add(回傳整理好的累積統計(報表2.星期二, 有沒有該星期判斷[3]));
            SiziwanCount.Add(回傳整理好的累積統計(報表2.星期三, 有沒有該星期判斷[4]));
            SiziwanCount.Add(回傳整理好的累積統計(報表2.星期四, 有沒有該星期判斷[5]));
            SiziwanCount.Add(回傳整理好的累積統計(報表2.星期五, 有沒有該星期判斷[6]));
            SiziwanCount.Add(回傳整理好的累積統計(報表2.星期六, 有沒有該星期判斷[7]));

            List<dynamic> SiziwanHourCount = new List<dynamic>();
            SiziwanHourCount.Add(回傳整理好的分時統計(報表2.星期日, 有沒有該星期判斷[1]));
            SiziwanHourCount.Add(回傳整理好的分時統計(報表2.星期一, 有沒有該星期判斷[2]));
            SiziwanHourCount.Add(回傳整理好的分時統計(報表2.星期二, 有沒有該星期判斷[3]));
            SiziwanHourCount.Add(回傳整理好的分時統計(報表2.星期三, 有沒有該星期判斷[4]));
            SiziwanHourCount.Add(回傳整理好的分時統計(報表2.星期四, 有沒有該星期判斷[5]));
            SiziwanHourCount.Add(回傳整理好的分時統計(報表2.星期五, 有沒有該星期判斷[6]));
            SiziwanHourCount.Add(回傳整理好的分時統計(報表2.星期六, 有沒有該星期判斷[7]));

            result.Add("SiziwanCount", SiziwanCount);
            result.Add("SiziwanHourCount", SiziwanHourCount);

            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("什麼都沒有唷");
        }
    }
    public List<ComeLeaveCount> 回傳整理好的分時統計(List<地區週內日分時流量Row> 星期, bool has)
    {
        List<ComeLeaveCount> _temp = new List<ComeLeaveCount>();
        foreach (var temp in 星期)
        {
            if (!temp.Hour.Equals("累積總車輛數"))
            {

                ComeLeaveCount tt = new ComeLeaveCount();
                tt.Hour = temp.Hour.Replace(":00", "");
                tt.ComeNums = temp.ComeHour;
                tt.LeaveNums = temp.LeaveHour;
                tt.StopNums = temp.StopHour;
                tt.has = has;
                _temp.Add(tt);
            }
        }
        return _temp;
    }

    public List<ComeLeaveCount> 回傳整理好的累積統計(List<地區週內日分時流量Row> 星期, bool has)
    {
        List<ComeLeaveCount> _temp = new List<ComeLeaveCount>();
        foreach (var temp in 星期)
        {
            if (!temp.Hour.Equals("累積總車輛數"))
            {
                ComeLeaveCount tt = new ComeLeaveCount();
                tt.Hour = temp.Hour.Replace(":00", "");
                tt.ComeNums = temp.Come;
                tt.LeaveNums = temp.Leave;
                tt.StopNums = temp.Stop;
                tt.has = has;
                _temp.Add(tt);
            }
        }
        return _temp;
    }



    public class ComeLeaveCount
    {
        public string Hour;
        public int ComeNums;
        public int LeaveNums;
        public int StopNums;
        public bool has;
    }


    public class eTag基本資料
    {
        public string ID;
        public string RoadName;
        public string date;
    }

    public class 地區週內日分時流量
    {
        public int 週內日;
        public int 小時;
        public int 數量;
    }

    public class 地區週內日分時流量Row
    {
        public string Hour;
        public int Come;
        public int Leave;
        public int Stop;
        public int ComeHour;
        public int LeaveHour;
        public int StopHour;
        public 地區週內日分時流量Row(string str)
        {
            Hour = str;
            Come = 0;
            Leave = 0;
            Stop = 0;
            ComeHour = 0;
            LeaveHour = 0;
            StopHour = 0;
        }
        public 地區週內日分時流量Row()
        {
            Come = 0;
            Leave = 0;
            Stop = 0;
            ComeHour = 0;
            LeaveHour = 0;
            StopHour = 0;
        }
    }

    public static List<地區週內日分時流量Row> 地區週內日分時流量Create()
    {
        List<地區週內日分時流量Row> 報表 = new List<地區週內日分時流量Row>();
        for (int i = 0; i < 24; i++)
        {
            地區週內日分時流量Row temp = new 地區週內日分時流量Row();
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
        報表.Add(new 地區週內日分時流量Row("累積總車輛數"));
        return 報表;
    }


    public class 地區週內日分時流量報表
    {
        public List<地區週內日分時流量Row> 星期日;
        public List<地區週內日分時流量Row> 星期一;
        public List<地區週內日分時流量Row> 星期二;
        public List<地區週內日分時流量Row> 星期三;
        public List<地區週內日分時流量Row> 星期四;
        public List<地區週內日分時流量Row> 星期五;
        public List<地區週內日分時流量Row> 星期六;
        public 地區週內日分時流量報表()
        {
            星期日 = 地區週內日分時流量Create();
            星期一 = 地區週內日分時流量Create();
            星期二 = 地區週內日分時流量Create();
            星期三 = 地區週內日分時流量Create();
            星期四 = 地區週內日分時流量Create();
            星期五 = 地區週內日分時流量Create();
            星期六 = 地區週內日分時流量Create();
        }
    }
    public void 計算滯留(地區週內日分時流量報表 報表, int 數量)
    {
        for (int i = 0; i < 24; i++)
        {
            報表.星期日[i].StopHour = 報表.星期日[i].ComeHour - 報表.星期日[i].LeaveHour + 數量;
            報表.星期一[i].StopHour = 報表.星期一[i].ComeHour - 報表.星期一[i].LeaveHour + 數量;
            報表.星期二[i].StopHour = 報表.星期二[i].ComeHour - 報表.星期二[i].LeaveHour + 數量;
            報表.星期三[i].StopHour = 報表.星期三[i].ComeHour - 報表.星期三[i].LeaveHour + 數量;
            報表.星期四[i].StopHour = 報表.星期四[i].ComeHour - 報表.星期四[i].LeaveHour + 數量;
            報表.星期五[i].StopHour = 報表.星期五[i].ComeHour - 報表.星期五[i].LeaveHour + 數量;
            報表.星期六[i].StopHour = 報表.星期六[i].ComeHour - 報表.星期六[i].LeaveHour + 數量;
        }
    }
    public void 計算進入累積(地區週內日分時流量報表 報表)
    {
        報表.星期日[0].Come = 報表.星期日[0].ComeHour;
        報表.星期一[0].Come = 報表.星期一[0].ComeHour;
        報表.星期二[0].Come = 報表.星期二[0].ComeHour;
        報表.星期三[0].Come = 報表.星期三[0].ComeHour;
        報表.星期四[0].Come = 報表.星期四[0].ComeHour;
        報表.星期五[0].Come = 報表.星期五[0].ComeHour;
        報表.星期六[0].Come = 報表.星期六[0].ComeHour;
        for (int i = 1; i < 24; i++)
        {
            報表.星期日[i].Come = 報表.星期日[i - 1].Come + 報表.星期日[i].ComeHour;
            報表.星期一[i].Come = 報表.星期一[i - 1].Come + 報表.星期一[i].ComeHour;
            報表.星期二[i].Come = 報表.星期二[i - 1].Come + 報表.星期二[i].ComeHour;
            報表.星期三[i].Come = 報表.星期三[i - 1].Come + 報表.星期三[i].ComeHour;
            報表.星期四[i].Come = 報表.星期四[i - 1].Come + 報表.星期四[i].ComeHour;
            報表.星期五[i].Come = 報表.星期五[i - 1].Come + 報表.星期五[i].ComeHour;
            報表.星期六[i].Come = 報表.星期六[i - 1].Come + 報表.星期六[i].ComeHour;
        }
        報表.星期日[24].ComeHour = 報表.星期日[23].Come;
        報表.星期一[24].ComeHour = 報表.星期一[23].Come;
        報表.星期二[24].ComeHour = 報表.星期二[23].Come;
        報表.星期三[24].ComeHour = 報表.星期三[23].Come;
        報表.星期四[24].ComeHour = 報表.星期四[23].Come;
        報表.星期五[24].ComeHour = 報表.星期五[23].Come;
        報表.星期六[24].ComeHour = 報表.星期六[23].Come;
        for (int i = 0; i < 24; i++)
        {
            報表.星期日[24].Come = 報表.星期日[24].Come + 報表.星期日[i].Come;
            報表.星期一[24].Come = 報表.星期一[24].Come + 報表.星期一[i].Come;
            報表.星期二[24].Come = 報表.星期二[24].Come + 報表.星期二[i].Come;
            報表.星期三[24].Come = 報表.星期三[24].Come + 報表.星期三[i].Come;
            報表.星期四[24].Come = 報表.星期四[24].Come + 報表.星期四[i].Come;
            報表.星期五[24].Come = 報表.星期五[24].Come + 報表.星期五[i].Come;
            報表.星期六[24].Come = 報表.星期六[24].Come + 報表.星期六[i].Come;
        }
    }
    public void 計算離開累積(地區週內日分時流量報表 報表)
    {
        報表.星期日[0].Leave = 報表.星期日[0].LeaveHour;
        報表.星期一[0].Leave = 報表.星期一[0].LeaveHour;
        報表.星期二[0].Leave = 報表.星期二[0].LeaveHour;
        報表.星期三[0].Leave = 報表.星期三[0].LeaveHour;
        報表.星期四[0].Leave = 報表.星期四[0].LeaveHour;
        報表.星期五[0].Leave = 報表.星期五[0].LeaveHour;
        報表.星期六[0].Leave = 報表.星期六[0].LeaveHour;
        for (int i = 1; i < 24; i++)
        {
            報表.星期日[i].Leave = 報表.星期日[i - 1].Leave + 報表.星期日[i].LeaveHour;
            報表.星期一[i].Leave = 報表.星期一[i - 1].Leave + 報表.星期一[i].LeaveHour;
            報表.星期二[i].Leave = 報表.星期二[i - 1].Leave + 報表.星期二[i].LeaveHour;
            報表.星期三[i].Leave = 報表.星期三[i - 1].Leave + 報表.星期三[i].LeaveHour;
            報表.星期四[i].Leave = 報表.星期四[i - 1].Leave + 報表.星期四[i].LeaveHour;
            報表.星期五[i].Leave = 報表.星期五[i - 1].Leave + 報表.星期五[i].LeaveHour;
            報表.星期六[i].Leave = 報表.星期六[i - 1].Leave + 報表.星期六[i].LeaveHour;
        }
        報表.星期日[24].LeaveHour = 報表.星期日[23].Leave;
        報表.星期一[24].LeaveHour = 報表.星期一[23].Leave;
        報表.星期二[24].LeaveHour = 報表.星期二[23].Leave;
        報表.星期三[24].LeaveHour = 報表.星期三[23].Leave;
        報表.星期四[24].LeaveHour = 報表.星期四[23].Leave;
        報表.星期五[24].LeaveHour = 報表.星期五[23].Leave;
        報表.星期六[24].LeaveHour = 報表.星期六[23].Leave;
        for (int i = 0; i < 24; i++)
        {
            報表.星期日[24].Leave = 報表.星期日[24].Leave + 報表.星期日[i].Leave;
            報表.星期一[24].Leave = 報表.星期一[24].Leave + 報表.星期一[i].Leave;
            報表.星期二[24].Leave = 報表.星期二[24].Leave + 報表.星期二[i].Leave;
            報表.星期三[24].Leave = 報表.星期三[24].Leave + 報表.星期三[i].Leave;
            報表.星期四[24].Leave = 報表.星期四[24].Leave + 報表.星期四[i].Leave;
            報表.星期五[24].Leave = 報表.星期五[24].Leave + 報表.星期五[i].Leave;
            報表.星期六[24].Leave = 報表.星期六[24].Leave + 報表.星期六[i].Leave;
        }
    }
    public void 計算滯留累積(地區週內日分時流量報表 報表)
    {
        報表.星期日[0].Stop = 報表.星期日[0].StopHour;
        報表.星期一[0].Stop = 報表.星期一[0].StopHour;
        報表.星期二[0].Stop = 報表.星期二[0].StopHour;
        報表.星期三[0].Stop = 報表.星期三[0].StopHour;
        報表.星期四[0].Stop = 報表.星期四[0].StopHour;
        報表.星期五[0].Stop = 報表.星期五[0].StopHour;
        報表.星期六[0].Stop = 報表.星期六[0].StopHour;
        for (int i = 1; i < 24; i++)
        {
            報表.星期日[i].Stop = 報表.星期日[i - 1].Stop + 報表.星期日[i].StopHour;
            報表.星期一[i].Stop = 報表.星期一[i - 1].Stop + 報表.星期一[i].StopHour;
            報表.星期二[i].Stop = 報表.星期二[i - 1].Stop + 報表.星期二[i].StopHour;
            報表.星期三[i].Stop = 報表.星期三[i - 1].Stop + 報表.星期三[i].StopHour;
            報表.星期四[i].Stop = 報表.星期四[i - 1].Stop + 報表.星期四[i].StopHour;
            報表.星期五[i].Stop = 報表.星期五[i - 1].Stop + 報表.星期五[i].StopHour;
            報表.星期六[i].Stop = 報表.星期六[i - 1].Stop + 報表.星期六[i].StopHour;
        }
        報表.星期日[24].StopHour = 報表.星期日[23].Stop;
        報表.星期一[24].StopHour = 報表.星期一[23].Stop;
        報表.星期二[24].StopHour = 報表.星期二[23].Stop;
        報表.星期三[24].StopHour = 報表.星期三[23].Stop;
        報表.星期四[24].StopHour = 報表.星期四[23].Stop;
        報表.星期五[24].StopHour = 報表.星期五[23].Stop;
        報表.星期六[24].StopHour = 報表.星期六[23].Stop;
        for (int i = 0; i < 24; i++)
        {
            報表.星期日[24].Stop = 報表.星期日[24].Stop + 報表.星期日[i].Stop;
            報表.星期一[24].Stop = 報表.星期一[24].Stop + 報表.星期一[i].Stop;
            報表.星期二[24].Stop = 報表.星期二[24].Stop + 報表.星期二[i].Stop;
            報表.星期三[24].Stop = 報表.星期三[24].Stop + 報表.星期三[i].Stop;
            報表.星期四[24].Stop = 報表.星期四[24].Stop + 報表.星期四[i].Stop;
            報表.星期五[24].Stop = 報表.星期五[24].Stop + 報表.星期五[i].Stop;
            報表.星期六[24].Stop = 報表.星期六[24].Stop + 報表.星期六[i].Stop;
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
public class 進入統計
{
    public int 進入;
}
public class 離開統計
{
    public int 離開;
}
public class 滯留統計
{
    public int 滯留;
}