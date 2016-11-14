using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// IdentityAuthority 的摘要描述
/// </summary>
public static class IdentityAuthority
{
    public static void check(HttpResponse Response, HttpRequest Request, HttpContext context)
    {
        string url = System.IO.Path.GetFileName(Request.PhysicalPath);
        if (url.Equals("check") || url.Equals("login") || UserInfo.loginValidation(context))
        {


        }
        else
        {
            Response.Redirect("~/login");
        }
    }
}