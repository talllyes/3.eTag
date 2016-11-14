using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// DateProcess 的摘要描述
/// </summary>
public static class DateProcess
{
    /// <summary>
    /// 將字串民國年轉西元年，格式為YYY-MM-DD
    /// </summary>
    /// <param name="str">日期</param>
    /// <param name="type">回傳類型</param>
    /// <returns>字串或日期</returns>
    public static string 民國年轉西元年回傳字串格式(dynamic str)
    {
        str = str.ToString();
        int year = Int32.Parse(str.Split('-')[0]) + 1911;
        DateTime date = DateTime.Parse(year + "-" + str.Split('-')[1] + "-" + str.Split('-')[2]);
        return date.ToString("yyyyMMdd");
    }
    public static DateTime 民國年轉西元年回傳日期格式(string str)
    {
        str = str.ToString();
        int year = Int32.Parse(str.Split('-')[0]) + 1911;
        DateTime date = DateTime.Parse(year + "-" + str.Split('-')[1] + "-" + str.Split('-')[2]);
        return date;
    }
    public static string 民國年轉西元年回傳字串格式(dynamic str, int day)
    {
        str = str.ToString();
        int year = Int32.Parse(str.Split('-')[0]) + 1911;
        DateTime date = DateTime.Parse(year + "-" + str.Split('-')[1] + "-" + str.Split('-')[2]);
        return date.AddDays(day).ToString("yyyyMMdd");
    }
    public static DateTime 民國年轉西元年回傳日期格式(dynamic str)
    {
        str = str.ToString();
        int year = Int32.Parse(str.Split('-')[0]) + 1911;
        DateTime date = DateTime.Parse(year + "-" + str.Split('-')[1] + "-" + str.Split('-')[2]);
        return date;
    }

    public static DateTime 民國年轉西元年回傳日期格式(dynamic str, int day)
    {
        str = str.ToString();
        int year = Int32.Parse(str.Split('-')[0]) + 1911;
        DateTime date = DateTime.Parse(year + "-" + str.Split('-')[1] + "-" + str.Split('-')[2]);
        return date.AddDays(day);
    }
    public static string 西元年轉民國年沒有分鐘回傳字串格式(dynamic str)
    {
        string dd;
        if (str != null)
        {
            string yyy = (Int32.Parse(str.ToString("yyyy")) - 1911).ToString();
            dd = yyy + "-" + str.ToString("MM-dd");
        }
        else
        {
            dd = "";
        }
        return dd;
    }
    public static string 西元年轉民國年字串格式(dynamic str)
    {
        string dd;
        if (str != null)
        {
            string yyy = (Int32.Parse(str.ToString("yyyy")) - 1911).ToString();
            dd = yyy + "-" + str.ToString("MM-dd HH:mm:ss");
        }
        else
        {
            dd = "";
        }
        return dd;
    }


}