
package com.hostel;

import java.io.IOException;
import java.sql.*;
import java.util.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/hostel")
public class HostelServlet extends HttpServlet {

    private String getModuleTable(String module) {
        switch (module) {
            case "students": return "web_students";
            case "rooms": return "web_rooms";
            case "allocations": return "web_allocations";
            case "fees": return "web_fees";
            case "attendance": return "web_attendance";
            case "complaints": return "web_complaints";
            default: return null;
        }
    }

    private String getIdColumn(String module) {
        switch (module) {
            case "students": return "student_id";
            case "rooms": return "room_id";
            case "allocations": return "allocation_id";
            case "fees": return "fee_id";
            case "attendance": return "attendance_id";
            case "complaints": return "complaint_id";
            default: return null;
        }
    }

    private boolean loggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("admin") != null;
    }

    private void message(HttpServletRequest request, String msg) {
        request.getSession().setAttribute("message", msg);
    }

    private void showLogin(HttpServletRequest request,
                           HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher(
            "/WEB-INF/views/login.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("logout".equals(action)) {
            HttpSession session = request.getSession(false);

            if (session != null) {
                session.invalidate();
            }

            response.sendRedirect(
                request.getContextPath() + "/hostel"
            );
            return;
        }

        if (!loggedIn(request)) {
            showLogin(request, response);
            return;
        }

        if (action == null || action.equals("dashboard")) {
            showDashboard(request, response);
            return;
        }

        if (action.equals("module")) {
            showModule(request, response);
            return;
        }

        showDashboard(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("login".equals(action)) {
            login(request, response);
            return;
        }

        if (!loggedIn(request)) {
            response.sendRedirect(
                request.getContextPath() + "/hostel"
            );
            return;
        }

        if ("save".equals(action)) {
            saveRecord(request, response);
        } else if ("delete".equals(action)) {
            deleteRecord(request, response);
        } else {
            response.sendRedirect(
                request.getContextPath() + "/hostel?action=dashboard"
            );
        }
    }

    private void login(HttpServletRequest request,
                       HttpServletResponse response)
            throws IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        String sql =
            "SELECT * FROM web_admin WHERE username=? AND password=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    HttpSession session = request.getSession();
                    session.setAttribute("admin", username);

                    response.sendRedirect(
                        request.getContextPath()
                        + "/hostel?action=dashboard"
                    );
                } else {
                    message(request, "Invalid username or password!");

                    response.sendRedirect(
                        request.getContextPath() + "/hostel"
                    );
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            message(request, "Database connection failed: " + e.getMessage());

            response.sendRedirect(
                request.getContextPath() + "/hostel"
            );
        }
    }

    private void showDashboard(HttpServletRequest request,
                               HttpServletResponse response)
            throws ServletException, IOException {

        int students = 0;
        int rooms = 0;
        int allocations = 0;
        double fees = 0;

        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement()) {

            ResultSet rs;

            rs = st.executeQuery(
                "SELECT COUNT(*) FROM web_students"
            );
            if (rs.next()) students = rs.getInt(1);
            rs.close();

            rs = st.executeQuery(
                "SELECT COUNT(*) FROM web_rooms"
            );
            if (rs.next()) rooms = rs.getInt(1);
            rs.close();

            rs = st.executeQuery(
                "SELECT COUNT(*) FROM web_allocations WHERE status='Active'"
            );
            if (rs.next()) allocations = rs.getInt(1);
            rs.close();

            rs = st.executeQuery(
                "SELECT COALESCE(SUM(amount),0) FROM web_fees WHERE payment_status='Paid'"
            );
            if (rs.next()) fees = rs.getDouble(1);
            rs.close();

        } catch (Exception e) {
            e.printStackTrace();
            message(request, "Dashboard error: " + e.getMessage());
        }

        request.setAttribute("students", students);
        request.setAttribute("rooms", rooms);
        request.setAttribute("allocations", allocations);
        request.setAttribute("fees", fees);

        request.getRequestDispatcher(
            "/WEB-INF/views/dashboard.jsp"
        ).forward(request, response);
    }

    private void showModule(HttpServletRequest request,
                            HttpServletResponse response)
            throws ServletException, IOException {

        String module = request.getParameter("name");
        String table = getModuleTable(module);
        String idColumn = getIdColumn(module);

        if (table == null) {
            response.sendRedirect(
                request.getContextPath() + "/hostel?action=dashboard"
            );
            return;
        }

        List<Map<String, String>> rows = new ArrayList<>();
        List<String> columns = new ArrayList<>();

        String sql = "SELECT * FROM " + table;

        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            ResultSetMetaData md = rs.getMetaData();

            for (int i = 1; i <= md.getColumnCount(); i++) {
                columns.add(md.getColumnName(i));
            }

            while (rs.next()) {
                Map<String, String> row = new LinkedHashMap<>();

                for (String column : columns) {
                    Object value = rs.getObject(column);
                    row.put(
                        column,
                        value == null ? "" : value.toString()
                    );
                }

                rows.add(row);
            }

        } catch (Exception e) {
            e.printStackTrace();
            message(request, "Could not load records: " + e.getMessage());
        }

        request.setAttribute("rows", rows);
        request.setAttribute("columns", columns);
        request.setAttribute("module", module);
        request.setAttribute("idColumn", idColumn);

        request.getRequestDispatcher(
            "/WEB-INF/views/module.jsp"
        ).forward(request, response);
    }

    private void saveRecord(HttpServletRequest request,
                            HttpServletResponse response)
            throws IOException {

        String module = request.getParameter("module");
        String table = getModuleTable(module);
        String idColumn = getIdColumn(module);
        String id = request.getParameter("id");

        if (table == null) {
            response.sendRedirect(
                request.getContextPath() + "/hostel?action=dashboard"
            );
            return;
        }

        String[] fields;
        String[] values;

        switch (module) {

            case "students":
                fields = new String[]{
                    "name", "gender", "phone", "email",
                    "course", "guardian_name",
                    "guardian_phone", "address"
                };
                break;

            case "rooms":
                fields = new String[]{
                    "room_number", "room_type",
                    "capacity", "monthly_fee"
                };
                break;

            case "allocations":
                fields = new String[]{
                    "student_id", "room_id",
                    "allocation_date", "vacate_date", "status"
                };
                break;

            case "fees":
                fields = new String[]{
                    "student_id", "amount", "payment_date",
                    "payment_month", "payment_status"
                };
                break;

            case "attendance":
                fields = new String[]{
                    "student_id", "attendance_date", "status"
                };
                break;

            case "complaints":
                fields = new String[]{
                    "student_id", "complaint",
                    "complaint_date", "status"
                };
                break;

            default:
                response.sendRedirect(
                    request.getContextPath() + "/hostel?action=dashboard"
                );
                return;
        }

        values = new String[fields.length];

        for (int i = 0; i < fields.length; i++) {
            values[i] = request.getParameter(fields[i]);

            if ("vacate_date".equals(fields[i])
                    && (values[i] == null || values[i].isEmpty())) {
                values[i] = null;
            }
        }

        boolean updating = id != null && !id.trim().isEmpty();

        StringBuilder sql = new StringBuilder();

        if (updating) {
            sql.append("UPDATE ").append(table).append(" SET ");

            for (int i = 0; i < fields.length; i++) {
                if (i > 0) sql.append(", ");
                sql.append(fields[i]).append("=?");
            }

            sql.append(" WHERE ").append(idColumn).append("=?");

        } else {
            sql.append("INSERT INTO ").append(table).append(" (");

            for (int i = 0; i < fields.length; i++) {
                if (i > 0) sql.append(", ");
                sql.append(fields[i]);
            }

            sql.append(") VALUES (");

            for (int i = 0; i < fields.length; i++) {
                if (i > 0) sql.append(", ");
                sql.append("?");
            }

            sql.append(")");
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < values.length; i++) {
                if (values[i] == null) {
                    ps.setNull(i + 1, Types.DATE);
                } else {
                    ps.setString(i + 1, values[i]);
                }
            }

            if (updating) {
                ps.setInt(fields.length + 1, Integer.parseInt(id));
            }

            ps.executeUpdate();

            message(request, updating
                ? "Record updated successfully!"
                : "Record added successfully!");

        } catch (Exception e) {
            e.printStackTrace();
            message(request, "Save failed: " + e.getMessage());
        }

        response.sendRedirect(
            request.getContextPath()
            + "/hostel?action=module&name=" + module
        );
    }

    private void deleteRecord(HttpServletRequest request,
                              HttpServletResponse response)
            throws IOException {

        String module = request.getParameter("module");
        String id = request.getParameter("id");

        String table = getModuleTable(module);
        String idColumn = getIdColumn(module);

        if (table == null || id == null) {
            response.sendRedirect(
                request.getContextPath() + "/hostel?action=dashboard"
            );
            return;
        }

        String sql = "DELETE FROM " + table
                   + " WHERE " + idColumn + "=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, Integer.parseInt(id));
            ps.executeUpdate();

            message(request, "Record deleted successfully!");

        } catch (Exception e) {
            e.printStackTrace();
            message(request,
                "Delete failed. This record may be linked to another record.");
        }

        response.sendRedirect(
            request.getContextPath()
            + "/hostel?action=module&name=" + module
        );
    }
}
