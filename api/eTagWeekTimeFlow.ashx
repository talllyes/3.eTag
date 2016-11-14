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
using System.Threading.Tasks;

public class eTagWeekTimeFlow : IHttpHandler, System.Web.SessionState.IRequiresSessionState
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
        else if (type.Equals("處理週內日分時流量資料"))
        {
            dynamic json = JValue.Parse(str);
            string tempDate = json.startDate;
            string tempDate2 = json.endDate;
            string startDate = DateProcess.民國年轉西元年回傳字串格式(tempDate);
            string endDate = DateProcess.民國年轉西元年回傳字串格式(tempDate2, 1);
            DateTime startDateD = DateProcess.民國年轉西元年回傳日期格式(tempDate);
            DateTime endDateD = DateProcess.民國年轉西元年回傳日期格式(tempDate2, 1);
            DateTime DendDateD = DateProcess.民國年轉西元年回傳日期格式(tempDate2);
            DateTime pstart = DateTime.Now;
            string name = "";
            Report insert;
            int result = (from a in DB2.Report
                          where a.Context == null && a.Type == 2
                          select a).Count();
            if (result < 3)
            {
                if (json.selectETag != null)
                {
                    bool first = true;
                    foreach (var tempSelectETag in json.selectETag)
                    {
                        if (first)
                        {
                            name = name + tempSelectETag.id;

                        }
                        else
                        {
                            name = "、" + name + tempSelectETag.id;
                        }
                    }
                    insert = new Report
                    {
                        ReportStartDate = startDateD,
                        ReportEndDate = DendDateD,
                        CreateDate = pstart,
                        Type = 2,
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
        else if (type.Equals("週內日分時流量資料"))
        {
            Task.Run(() => 週內日分時流量資料(DB, DB2, context, str));
        }
        else
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("什麼都沒有唷");
        }
    }
    public void 週內日分時流量資料(DataClasses3DataContext DB, DataClassesDataContext DB2, HttpContext context, string str)
    {
        dynamic json = JValue.Parse(str);
        string tempDate = json.startDate;
        string tempDate2 = json.endDate;
        string startDate = DateProcess.民國年轉西元年回傳字串格式(tempDate);
        string endDate = DateProcess.民國年轉西元年回傳字串格式(tempDate2, 1);
        DateTime startDateD = DateProcess.民國年轉西元年回傳日期格式(tempDate);
        DateTime endDateD = DateProcess.民國年轉西元年回傳日期格式(tempDate2, 1);


        Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();

        if (json.selectETag != null)
        {
            ExcelCreate Excel = new ExcelCreate("1");
            List<string> tempTitle = new List<string>();
            foreach (var tempSelectETag in json.selectETag)
            {
                eTag分時流量報表 報表 = new eTag分時流量報表();
                string sql = @"SELECT CONVERT(varchar(100),RECEIVEDATE, 112) 日期,
                           DatePart(WeekDay,RECEIVEDATE) 週內日,
                           datepart(hh,RECEIVEDATE) 小時,
                           count(*) 數量,SUBSTRING([PLATEID],6,1) 車種
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                                     where [RECEIVEDATE]>='" + startDate + @"'
                                     and [RECEIVEDATE]<'" + endDate + @"'
                                     and [DEVICEID]='" + tempSelectETag.id + @"'";
                foreach (var notDateListTemp in json.notDateList)
                {
                    string ttTemp = DateProcess.民國年轉西元年回傳字串格式(notDateListTemp.date);
                    sql = sql + @"and CONVERT(varchar(100), [RECEIVEDATE], 112)!='" + ttTemp + "'";
                }
                sql = sql + @"group by CONVERT(varchar(100),RECEIVEDATE, 112),
                           DatePart(WeekDay,RECEIVEDATE),datepart(hh,RECEIVEDATE),SUBSTRING([PLATEID],6,1)";

                var eTag週內日分時流量 = DB.ExecuteQuery<eTag週內日分時流量>(sql);
                foreach (var temp in eTag週內日分時流量)
                {
                    if (temp.週內日 == 1)
                    {
                        儲存報表數量(報表.星期日[temp.小時], temp.車種, temp.數量);
                    }
                    else if (temp.週內日 == 2)
                    {
                        儲存報表數量(報表.星期一[temp.小時], temp.車種, temp.數量);
                    }
                    else if (temp.週內日 == 3)
                    {
                        儲存報表數量(報表.星期二[temp.小時], temp.車種, temp.數量);
                    }
                    else if (temp.週內日 == 4)
                    {
                        儲存報表數量(報表.星期三[temp.小時], temp.車種, temp.數量);
                    }
                    else if (temp.週內日 == 5)
                    {
                        儲存報表數量(報表.星期四[temp.小時], temp.車種, temp.數量);
                    }
                    else if (temp.週內日 == 6)
                    {
                        儲存報表數量(報表.星期五[temp.小時], temp.車種, temp.數量);
                    }
                    else if (temp.週內日 == 7)
                    {
                        儲存報表數量(報表.星期六[temp.小時], temp.車種, temp.數量);
                    }
                }

                計算總流量(報表);



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

                平均計算(報表);

                string tempID = tempSelectETag.id;
                eTag基本資料 baseInfo = new eTag基本資料();
                baseInfo.date = tempDate + " ~ " + tempDate2;
                baseInfo.ID = tempSelectETag.id;
                baseInfo.RoadName = tempSelectETag.title;

                Excel.sheetCreate("週日");
                Excel.設定週日內分時流量報表標題(tempDate, "(" + tempSelectETag.id + ")" + tempSelectETag.title, "週日");
                foreach (var reportTemp in 報表.星期日)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(reportTemp.Hour);
                    textTemp.Add(reportTemp.AllNums);
                    textTemp.Add(reportTemp.SBigCarNums);
                    textTemp.Add(reportTemp.BigCarNums);
                    textTemp.Add(reportTemp.SmallCarNums);
                    textTemp.Add(reportTemp.OtherCarNums);
                    Excel.分時流量新增(textTemp);
                }
                Excel.setFooter();
                Excel.sheetCreate("週一");
                Excel.設定週日內分時流量報表標題(tempDate, "(" + tempSelectETag.id + ")" + tempSelectETag.title, "週一");
                foreach (var reportTemp in 報表.星期一)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(reportTemp.Hour);
                    textTemp.Add(reportTemp.AllNums);
                    textTemp.Add(reportTemp.SBigCarNums);
                    textTemp.Add(reportTemp.BigCarNums);
                    textTemp.Add(reportTemp.SmallCarNums);
                    textTemp.Add(reportTemp.OtherCarNums);
                    Excel.分時流量新增(textTemp);
                }
                Excel.setFooter();
                Excel.sheetCreate("週二");
                Excel.設定週日內分時流量報表標題(tempDate, "(" + tempSelectETag.id + ")" + tempSelectETag.title, "週二");
                foreach (var reportTemp in 報表.星期二)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(reportTemp.Hour);
                    textTemp.Add(reportTemp.AllNums);
                    textTemp.Add(reportTemp.SBigCarNums);
                    textTemp.Add(reportTemp.BigCarNums);
                    textTemp.Add(reportTemp.SmallCarNums);
                    textTemp.Add(reportTemp.OtherCarNums);
                    Excel.分時流量新增(textTemp);
                }
                Excel.setFooter();
                Excel.sheetCreate("週三");
                Excel.設定週日內分時流量報表標題(tempDate, "(" + tempSelectETag.id + ")" + tempSelectETag.title, "週三");
                foreach (var reportTemp in 報表.星期三)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(reportTemp.Hour);
                    textTemp.Add(reportTemp.AllNums);
                    textTemp.Add(reportTemp.SBigCarNums);
                    textTemp.Add(reportTemp.BigCarNums);
                    textTemp.Add(reportTemp.SmallCarNums);
                    textTemp.Add(reportTemp.OtherCarNums);
                    Excel.分時流量新增(textTemp);
                }
                Excel.setFooter();
                Excel.sheetCreate("週四");
                Excel.設定週日內分時流量報表標題(tempDate, "(" + tempSelectETag.id + ")" + tempSelectETag.title, "週四");
                foreach (var reportTemp in 報表.星期四)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(reportTemp.Hour);
                    textTemp.Add(reportTemp.AllNums);
                    textTemp.Add(reportTemp.SBigCarNums);
                    textTemp.Add(reportTemp.BigCarNums);
                    textTemp.Add(reportTemp.SmallCarNums);
                    textTemp.Add(reportTemp.OtherCarNums);
                    Excel.分時流量新增(textTemp);
                }
                Excel.setFooter();
                Excel.sheetCreate("週五");
                Excel.設定週日內分時流量報表標題(tempDate, "(" + tempSelectETag.id + ")" + tempSelectETag.title, "週五");
                foreach (var reportTemp in 報表.星期五)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(reportTemp.Hour);
                    textTemp.Add(reportTemp.AllNums);
                    textTemp.Add(reportTemp.SBigCarNums);
                    textTemp.Add(reportTemp.BigCarNums);
                    textTemp.Add(reportTemp.SmallCarNums);
                    textTemp.Add(reportTemp.OtherCarNums);
                    Excel.分時流量新增(textTemp);
                }
                Excel.setFooter();
                Excel.sheetCreate("週六");
                Excel.設定週日內分時流量報表標題(tempDate, "(" + tempSelectETag.id + ")" + tempSelectETag.title, "週六");
                foreach (var reportTemp in 報表.星期六)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(reportTemp.Hour);
                    textTemp.Add(reportTemp.AllNums);
                    textTemp.Add(reportTemp.SBigCarNums);
                    textTemp.Add(reportTemp.BigCarNums);
                    textTemp.Add(reportTemp.SmallCarNums);
                    textTemp.Add(reportTemp.OtherCarNums);
                    Excel.分時流量新增(textTemp);
                }
                Excel.setFooter();
                result.Add("baseInfo", baseInfo);
                result.Add("report", 報表);
            }
            Excel.excelOutput(context.Request, "週內日分時流量報表");
        }
        int reportid = json.reportid;
        var update = (from b in DB2.Report
                      where b.ReportID == reportid
                      select b).FirstOrDefault();
        update.Context = JsonConvert.SerializeObject(result);
        update.EndDate = DateTime.Now;

        DB2.SubmitChanges();
    }




    public void 儲存報表數量(eTag分時流量報表Row 報表, string 車種, int 數量)
    {
        if (車種 == "3")
        {
            報表.SmallCarNums = 報表.SmallCarNums + 數量;
        }
        else if (車種 == "4")
        {
            報表.BigCarNums = 報表.BigCarNums + 數量;
        }
        else if (車種 == "5")
        {
            報表.SBigCarNums = 報表.SBigCarNums + 數量;
        }
        else
        {
            報表.OtherCarNums = 報表.OtherCarNums + 數量;
        }
    }

    public class eTag基本資料
    {
        public string ID;
        public string RoadName;
        public string date;
    }

    public class eTag週內日分時流量
    {
        public string 日期;
        public string 車種;
        public int 週內日;
        public int 小時;
        public int 數量;
    }

    public class eTag分時流量報表Row
    {
        public string Hour;
        public int AllNums;
        public int SBigCarNums;
        public int BigCarNums;
        public int SmallCarNums;
        public int OtherCarNums;
        public eTag分時流量報表Row(string str)
        {
            Hour = str;
            AllNums = 0;
            SBigCarNums = 0;
            BigCarNums = 0;
            SmallCarNums = 0;
            OtherCarNums = 0;
        }
        public eTag分時流量報表Row()
        {
            AllNums = 0;
            SBigCarNums = 0;
            BigCarNums = 0;
            SmallCarNums = 0;
            OtherCarNums = 0;
        }
    }

    public static List<eTag分時流量報表Row> eTag分時流量報表Create()
    {
        List<eTag分時流量報表Row> 報表 = new List<eTag分時流量報表Row>();
        for (int i = 0; i < 24; i++)
        {
            eTag分時流量報表Row temp = new eTag分時流量報表Row();
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
        報表.Add(new eTag分時流量報表Row("晨峰"));
        報表.Add(new eTag分時流量報表Row("昏峰"));
        報表.Add(new eTag分時流量報表Row("離峰"));
        報表.Add(new eTag分時流量報表Row("全日"));
        報表.Add(new eTag分時流量報表Row("全日加總"));
        return 報表;
    }


    public class eTag分時流量報表
    {
        public List<eTag分時流量報表Row> 星期日;
        public List<eTag分時流量報表Row> 星期一;
        public List<eTag分時流量報表Row> 星期二;
        public List<eTag分時流量報表Row> 星期三;
        public List<eTag分時流量報表Row> 星期四;
        public List<eTag分時流量報表Row> 星期五;
        public List<eTag分時流量報表Row> 星期六;
        public eTag分時流量報表()
        {
            星期日 = eTag分時流量報表Create();
            星期一 = eTag分時流量報表Create();
            星期二 = eTag分時流量報表Create();
            星期三 = eTag分時流量報表Create();
            星期四 = eTag分時流量報表Create();
            星期五 = eTag分時流量報表Create();
            星期六 = eTag分時流量報表Create();
        }
    }
    public void 計算平均值(List<eTag分時流量報表Row> 星期, int n)
    {
        int temp = 1;
        if (n != 0)
        {
            temp = n;
        }
        for (int i = 0; i < 24; i++)
        {
            星期[i].AllNums = 星期[i].AllNums / temp;
            星期[i].SBigCarNums = 星期[i].SBigCarNums / temp;
            星期[i].BigCarNums = 星期[i].BigCarNums / temp;
            星期[i].SmallCarNums = 星期[i].SmallCarNums / temp;
            星期[i].OtherCarNums = 星期[i].OtherCarNums / temp;
        }
    }



    public void 計算總流量(eTag分時流量報表 報表)
    {
        總流量加總(報表.星期日);
        總流量加總(報表.星期一);
        總流量加總(報表.星期二);
        總流量加總(報表.星期三);
        總流量加總(報表.星期四);
        總流量加總(報表.星期五);
        總流量加總(報表.星期六);
    }

    public void 總流量加總(List<eTag分時流量報表Row> 星期)
    {
        for (int i = 0; i < 24; i++)
        {
            星期[i].AllNums = 星期[i].SBigCarNums + 星期[i].BigCarNums + 星期[i].SmallCarNums + 星期[i].OtherCarNums;
        }
    }

    public void 平均計算(eTag分時流量報表 報表)
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
    public void 晨峰計算(List<eTag分時流量報表Row> 星期)
    {
        星期[24].AllNums = (星期[7].AllNums + 星期[8].AllNums) / 2;
        星期[24].SBigCarNums = (星期[7].SBigCarNums + 星期[8].SBigCarNums) / 2;
        星期[24].BigCarNums = (星期[7].BigCarNums + 星期[8].BigCarNums) / 2;
        星期[24].SmallCarNums = (星期[7].SmallCarNums + 星期[8].SmallCarNums) / 2;
        星期[24].OtherCarNums = (星期[7].OtherCarNums + 星期[8].OtherCarNums) / 2;
    }
    public void 昏峰計算(List<eTag分時流量報表Row> 星期)
    {
        星期[25].AllNums = (星期[17].AllNums + 星期[18].AllNums) / 2;
        星期[25].SBigCarNums = (星期[17].SBigCarNums + 星期[18].SBigCarNums) / 2;
        星期[25].BigCarNums = (星期[17].BigCarNums + 星期[18].BigCarNums) / 2;
        星期[25].SmallCarNums = (星期[17].SmallCarNums + 星期[18].SmallCarNums) / 2;
        星期[25].OtherCarNums = (星期[17].OtherCarNums + 星期[18].OtherCarNums) / 2;
    }

    public void 離峰計算(List<eTag分時流量報表Row> 星期)
    {
        for (int i = 9; i < 17; i++)
        {
            星期[26].AllNums = 星期[26].AllNums + 星期[i].AllNums;
            星期[26].SBigCarNums = 星期[26].SBigCarNums + 星期[i].SBigCarNums;
            星期[26].BigCarNums = 星期[26].BigCarNums + 星期[i].BigCarNums;
            星期[26].SmallCarNums = 星期[26].SmallCarNums + 星期[i].SmallCarNums;
            星期[26].OtherCarNums = 星期[26].OtherCarNums + 星期[i].OtherCarNums;
        }
        星期[26].AllNums = 星期[26].AllNums / 8;
        星期[26].SBigCarNums = 星期[26].SBigCarNums / 8;
        星期[26].BigCarNums = 星期[26].BigCarNums / 8;
        星期[26].SmallCarNums = 星期[26].SmallCarNums / 8;
        星期[26].OtherCarNums = 星期[26].OtherCarNums / 8;
    }

    public void 全日計算(List<eTag分時流量報表Row> 星期)
    {
        for (int j = 0; j < 24; j++)
        {
            星期[27].AllNums = 星期[27].AllNums + 星期[j].AllNums;
            星期[27].SBigCarNums = 星期[27].SBigCarNums + 星期[j].SBigCarNums;
            星期[27].BigCarNums = 星期[27].BigCarNums + 星期[j].BigCarNums;
            星期[27].SmallCarNums = 星期[27].SmallCarNums + 星期[j].SmallCarNums;
            星期[27].OtherCarNums = 星期[27].OtherCarNums + 星期[j].OtherCarNums;
        }
        星期[28].AllNums = 星期[27].AllNums;
        星期[28].SBigCarNums = 星期[27].SBigCarNums;
        星期[28].BigCarNums = 星期[27].BigCarNums;
        星期[28].SmallCarNums = 星期[27].SmallCarNums;
        星期[28].OtherCarNums = 星期[27].OtherCarNums;

        星期[27].AllNums = 星期[27].AllNums / 24;
        星期[27].SBigCarNums = 星期[27].SBigCarNums / 24;
        星期[27].BigCarNums = 星期[27].BigCarNums / 24;
        星期[27].SmallCarNums = 星期[27].SmallCarNums / 24;
        星期[27].OtherCarNums = 星期[27].OtherCarNums / 24;
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}