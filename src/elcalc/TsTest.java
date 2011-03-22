package elcalc;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class TsTest extends HttpServlet {

  int count = 0;

  public void doGet(HttpServletRequest request, HttpServletResponse response)
    throws IOException, ServletException{

    response.setContentType("text/html; charset=Shift_JIS");
    PrintWriter out = response.getWriter();

    StringBuffer sb = new StringBuffer();

    sb.append("<html>");
    sb.append("<head>");
    sb.append("<title>サンプル</title>");
    sb.append("</head>");
    sb.append("<body>");

    count++;
    sb.append("<p>訪問人数:");
    sb.append(count);
    sb.append("</p>");

    Count cnt = new Count();
    int count2 = cnt.doIncrement();
    sb.append("<p>訪問人数2:");
    sb.append(count2);
    sb.append("</p>");



    sb.append("</body>");
    sb.append("</html>");

    out.println(new String(sb));

    out.close();
  }
}

