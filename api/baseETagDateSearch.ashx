<%@ WebHandler Language="C#" Class="baseETagDateSearch" %>

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

public class baseETagDateSearch : IHttpHandler, System.Web.SessionState.IRequiresSessionState
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
        else if (type.Equals("eTag原始資料"))
        {
            dynamic json = JValue.Parse(str);
            string startDate = DateProcess.民國年轉西元年回傳字串格式(json.startDate) + " " + json.startHH + ":" + json.startMM;
            string endDate = DateProcess.民國年轉西元年回傳字串格式(json.endDate) + " " + json.endHH + ":" + json.endMM;
            string eTag = json.eTag;

            string sql = @"SELECT TOP 100000 [DEVICEID],CONVERT(varchar(100), [RECEIVEDATE], 120) RECEIVEDATE,[LANEID],[PLATEID],
                           case when SUBSTRING([PLATEID],6,1)='3' then '小型車' when SUBSTRING([PLATEID],6,1)='4' then '大型車'
                           when SUBSTRING([PLATEID],6,1)='5' then '聯結車' else '其他' end as CarType
                           FROM [UTCS_Base_KS].[dbo].[ETAG_VEHICLE]
                           where RECEIVEDATE>'" + startDate + @"' and RECEIVEDATE<'" + endDate + @"'";

            if (!eTag.Equals(""))
            {
                sql = sql + "and [PLATEID]='" + eTag + "'";

            }

            bool cETag = true;
            foreach (var temp in json.selectETag)
            {
                if (cETag)
                {
                    sql = sql + "and ([DEVICEID]='" + temp + "'";
                    cETag = false;
                }
                else
                {
                    sql = sql + "or [DEVICEID]='" + temp + "'";
                }
            }
            if (!cETag)
            {
                sql = sql + ") order by RECEIVEDATE desc";
            }
            var result = DB.ExecuteQuery<ETagBaseData>(sql);
            IList<ETagBaseData> excelUse = new List<ETagBaseData>(result);
            ExcelCreate excelDownload = new ExcelCreate();
            List<dynamic> title = new List<dynamic>();
            title.Add("設備ID");
            title.Add("時間");
            title.Add("車種");
            title.Add("eTag碼");
            excelDownload.setTitle(title);
            List<dynamic> width = new List<dynamic>();
            width.Add(10);
            width.Add(20);
            width.Add(10);
            width.Add(25);
            excelDownload.setWidth(width);
            foreach (var temp in excelUse)
            {
                List<dynamic> contextTemp = new List<dynamic>();
                contextTemp.Add(temp.DEVICEID);
                contextTemp.Add(temp.RECEIVEDATE);
                contextTemp.Add(temp.CarType);
                contextTemp.Add(temp.PLATEID);
                excelDownload.insertRow(contextTemp);
            }
            excelDownload.excelOutput(context.Request, "eTag原始資料");
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(excelUse));
            GC.Collect();
            GC.WaitForPendingFinalizers();
        }
        else
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("什麼都沒有唷");
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