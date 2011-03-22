package elcalc;

import java.io.IOException;
import javax.servlet.http.*;

public class CalcBase extends HttpServlet {
    public void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("text/plain");
        resp.getWriter().println("It's a calc base.");
    }
}
