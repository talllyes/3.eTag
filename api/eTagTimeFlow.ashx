<%@ WebHandler Language="C#" Class="eTagTimeFlow" %>

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

public class eTagTimeFlow : IHttpHandler, System.Web.SessionState.IRequiresSessionState
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
        else if (type.Equals("分時流量資料"))
        {
            dynamic json = JValue.Parse(str);
            string tempDate = json.startDate;
            string startDate = DateProcess.民國年轉西元年回傳字串格式(tempDate);
            string endDate = DateProcess.民國年轉西元年回傳字串格式(tempDate, 1);
            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();

            if (json.selectETag != null)
            {
                ExcelCreate Excel = new ExcelCreate("1");
                List<string> tempTitle = new List<string>();
                foreach (var tempSelectETag in json.selectETag)
                {
                    eTag分時流量報表 報表 = new eTag分時流量報表();
                    Dictionary<string, dynamic> 基本資料 = new Dictionary<string, dynamic>();

                    Excel.sheetCreate((string)tempSelectETag.id);
                    Excel.設定分時流量報表標題(tempDate, "(" + tempSelectETag.id + ")" + tempSelectETag.title);
                    string sql = @"
                                     SELECT datepart(hh,RECEIVEDATE) Hour,DEVICEID,
                                     SUBSTRING([PLATEID],6,1) CarType,
                                     count(*) Nums
                                     FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                                     where [RECEIVEDATE]>'" + startDate + @"'
                                     and [RECEIVEDATE]<'" + endDate + @"'
                                     and ([DEVICEID]='" + tempSelectETag.id + @"'
                                     ) group by datepart(hh,RECEIVEDATE),DEVICEID,SUBSTRING([PLATEID],6,1)";
                    var eTag分時流量 = DB.ExecuteQuery<eTag分時流量>(sql);
                    foreach (var temp in eTag分時流量)
                    {
                        if (temp.CarType == "3")
                        {
                            報表.報表[temp.Hour].SmallCarNums = temp.Nums;
                        }
                        else if (temp.CarType == "4")
                        {
                            報表.報表[temp.Hour].BigCarNums = temp.Nums;
                        }
                        else if (temp.CarType == "5")
                        {
                            報表.報表[temp.Hour].SBigCarNums = temp.Nums;
                        }
                        else
                        {
                            報表.報表[temp.Hour].OtherCarNums = 報表.報表[temp.Hour].OtherCarNums + temp.Nums;
                        }
                        報表.報表[temp.Hour].AllNums = 報表.報表[temp.Hour].AllNums + temp.Nums;
                    }

                    //晨峰7-9
                    報表.報表[24].AllNums = (報表.報表[7].AllNums + 報表.報表[8].AllNums) / 2;
                    報表.報表[24].SBigCarNums = (報表.報表[7].SBigCarNums + 報表.報表[8].SBigCarNums) / 2;
                    報表.報表[24].BigCarNums = (報表.報表[7].BigCarNums + 報表.報表[8].BigCarNums) / 2;
                    報表.報表[24].SmallCarNums = (報表.報表[7].SmallCarNums + 報表.報表[8].SmallCarNums) / 2;
                    報表.報表[24].OtherCarNums = (報表.報表[7].OtherCarNums + 報表.報表[8].OtherCarNums) / 2;
                    //昏峰17-19
                    報表.報表[25].AllNums = (報表.報表[17].AllNums + 報表.報表[18].AllNums) / 2;
                    報表.報表[25].SBigCarNums = (報表.報表[17].SBigCarNums + 報表.報表[18].SBigCarNums) / 2;
                    報表.報表[25].BigCarNums = (報表.報表[17].BigCarNums + 報表.報表[18].BigCarNums) / 2;
                    報表.報表[25].SmallCarNums = (報表.報表[17].SmallCarNums + 報表.報表[18].SmallCarNums) / 2;
                    報表.報表[25].OtherCarNums = (報表.報表[17].OtherCarNums + 報表.報表[18].OtherCarNums) / 2;
                    //離峰9-17
                    for (int j = 9; j < 17; j++)
                    {
                        報表.報表[26].AllNums = (報表.報表[26].AllNums + 報表.報表[j].AllNums) / 8;
                        報表.報表[26].SBigCarNums = (報表.報表[26].SBigCarNums + 報表.報表[j].SBigCarNums) / 8;
                        報表.報表[26].BigCarNums = (報表.報表[26].BigCarNums + 報表.報表[j].BigCarNums) / 8;
                        報表.報表[26].SmallCarNums = (報表.報表[26].SmallCarNums + 報表.報表[j].SmallCarNums) / 8;
                        報表.報表[26].OtherCarNums = (報表.報表[26].OtherCarNums + 報表.報表[j].OtherCarNums) / 8;
                    }
                    //全日                        
                    for (int j = 0; j < 24; j++)
                    {
                        報表.報表[27].AllNums = 報表.報表[27].AllNums + 報表.報表[j].AllNums;
                        報表.報表[27].SBigCarNums = 報表.報表[27].SBigCarNums + 報表.報表[j].SBigCarNums;
                        報表.報表[27].BigCarNums = 報表.報表[27].BigCarNums + 報表.報表[j].BigCarNums;
                        報表.報表[27].SmallCarNums = 報表.報表[27].SmallCarNums + 報表.報表[j].SmallCarNums;
                        報表.報表[27].OtherCarNums = 報表.報表[27].OtherCarNums + 報表.報表[j].OtherCarNums;
                    }
                    報表.報表[28].AllNums = 報表.報表[27].AllNums;
                    報表.報表[28].SBigCarNums = 報表.報表[27].SBigCarNums;
                    報表.報表[28].BigCarNums = 報表.報表[27].BigCarNums;
                    報表.報表[28].SmallCarNums = 報表.報表[27].SmallCarNums;
                    報表.報表[28].OtherCarNums = 報表.報表[27].OtherCarNums;
                    報表.報表[27].AllNums = 報表.報表[27].AllNums / 24;
                    報表.報表[27].SBigCarNums = 報表.報表[27].SBigCarNums / 24;
                    報表.報表[27].BigCarNums = 報表.報表[27].BigCarNums / 24;
                    報表.報表[27].SmallCarNums = 報表.報表[27].SmallCarNums / 24;
                    報表.報表[27].OtherCarNums = 報表.報表[27].OtherCarNums / 24;
                    string tempID = tempSelectETag.id;
                    eTag基本資料 baseInfo = new eTag基本資料();
                    baseInfo.date = tempDate;
                    baseInfo.ID = tempSelectETag.id;
                    baseInfo.RoadName = tempSelectETag.title;
                    foreach (var reportTemp in 報表.報表)
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
                    基本資料.Add("baseInfo", baseInfo);
                    基本資料.Add("report", 報表.報表);
                    result.Add("ID" + tempID, 基本資料);
                }
                Excel.excelOutput(context.Request, "分時流量報表");
            }

            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("什麼都沒有唷");
        }
    }
    public class eTag基本資料
    {
        public string ID;
        public string RoadName;
        public string date;
    }

    public class eTag分時流量
    {
        public int Hour;
        public int Nums;
        public string CarType;
        public string DEVICEID;
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

    public class eTag分時流量報表
    {
        public List<eTag分時流量報表Row> 報表;

        public eTag分時流量報表()
        {
            報表 = new List<eTag分時流量報表Row>();
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