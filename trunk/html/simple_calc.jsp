<%@   page contentType="text/html;charset=Shift_JIS" language="java"
%><%@ page import="elcalc.SimpleCalc"
%><%@ page import="java.util.HashMap" %>
<%
    String dmsg = "test damage";
    String log  = "not param";
    String send_title = "戦闘計算機";
    SimpleCalc s = new SimpleCalc();
    s.doCalc( request, response);
    HashMap param = new HashMap();
    param.put("ps",s.getPs());
    param.put("sr","1");
    param.put("main_expr","1");
    param.put("sub_expr","1");
    param.put("ap","0");
    if ( !s.getBaseValue().equals(""))
    {
        log = "having param";
        dmsg = s.getBaseValue();
    }
%>

<jsp:include page="include_header.jsp" flush="true">
   <jsp:param name="_page_title" value="<%=new String(java.net.URLEncoder.encode(send_title,\"Windows-31j\"))%>" />
   <jsp:param name="_body_title" value="<%=new String(java.net.URLEncoder.encode(send_title,\"Windows-31j\"))%>" />
</jsp:include>

** <%=log%><br />
<font color="#ff0000"><%=dmsg%></font>
<form target="_self" method="get">

<br /><br /><br />


<a href="#a" accesskey="1">A</a>/<a href="#b" accesskey="2">B</a>/<a href="#c" accesskey="3">C</a>/<a href="#d" accesskey="4">D</a>
<a name="a"><hr style="border-style:solid; border-color:#FFC382;" /><div style="background-color:#FFC382;text-align:center;color:#550000">-A-</div><hr style="border-style:solid; border-color:#FFC382;" /></a>
ＰＳ　　　：<input type="text" size="4" maxlength="4" name="ps" value="<%=(String)param.get("ps")%>" istyle="4" mode="numeric" /><br />
ｽｷﾙ係数　 ：<input type="text" size="5" maxlength="5" name="sr" value="<%=(String)param.get("sr")%>" istyle="4" mode="numeric" /><br />
熟練度(主)：<input type="text" size="5" maxlength="5" name="main_expr" value="<%=(String)param.get("main_expr")%>" istyle="4" mode="numeric" /><br />
熟練度(副)：<input type="text" size="5" maxlength="5" name="sub_expr" value="<%=(String)param.get("sub_expr")%>" istyle="4" mode="numeric" /><br />



<a name="d"><hr style="border-style:solid; border-color:#FFC382;" /><div style="background-color:#FFC382;text-align:center;color:#550000">-D-</div><hr style="border-style:solid; border-color:#FFC382;" /></a>
防御：<input type="text" name="ap" size="5" maxlength="5"  value="<%=(String)param.get("ap")%>" istyle="4" mode="numeric" /><br />

<input type="submit" name="calc" value="8.計算!"  accesskey="8" />
<input type="submit" name="calc_all" value="9.全ﾊﾟﾀｰﾝ計算!"  accesskey="9" />
</form>
<div style="background-color:#FFC382;text-align:center;color:#550000"><%=s.getVersion()%></div>

<jsp:include page="include_footer.jsp" flush="true" />
