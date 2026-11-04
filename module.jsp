
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>

<%!
    public String esc(Object value) {
        if (value == null) return "";

        String s = String.valueOf(value);

        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect(request.getContextPath() + "/hostel");
        return;
    }

    String module = (String) request.getAttribute("module");

    List<Map<String, String>> rows =
        (List<Map<String, String>>) request.getAttribute("rows");

    List<String> columns =
        (List<String>) request.getAttribute("columns");

    String msg = (String) session.getAttribute("message");
    session.removeAttribute("message");

    String title = "Management";

    if ("students".equals(module)) title = "Student Management";
    if ("rooms".equals(module)) title = "Room Management";
    if ("allocations".equals(module)) title = "Room Allocation";
    if ("fees".equals(module)) title = "Fee Management";
    if ("attendance".equals(module)) title = "Attendance Management";
    if ("complaints".equals(module)) title = "Complaint Management";
%>

<!DOCTYPE html>
<html>
<head>
    <title><%=title%></title>

    <link rel="stylesheet"
          href="<%=request.getContextPath()%>/css/style.css">

    <script>
        function editRow(button) {

            var row = button.closest("tr");

            var form = document.getElementById("recordForm");

            form.reset();

            row.querySelectorAll("td[data-col]").forEach(function(cell) {

                var field = cell.getAttribute("data-col");
                var value = cell.getAttribute("data-value");

                var input = form.elements[field];

                if (input) {
                    input.value = value;
                }
            });

            document.getElementById("recordId").value =
                row.getAttribute("data-id");

            document.getElementById("formHeading").innerText =
                "Update Record";

            document.getElementById("saveButton").innerText =
                "Update Record";

            window.scrollTo(0, 0);
        }

        function clearForm() {

            var form = document.getElementById("recordForm");

            form.reset();

            document.getElementById("recordId").value = "";

            document.getElementById("formHeading").innerText =
                "Add New Record";

            document.getElementById("saveButton").innerText =
                "Save Record";
        }
    </script>
</head>

<body>

<div class="sidebar">

    <h2>🏨 Hostel Admin</h2>

    <a href="<%=request.getContextPath()%>/hostel?action=dashboard">
        Dashboard
    </a>

    <a href="<%=request.getContextPath()%>/hostel?action=module&name=students">
        Students
    </a>

    <a href="<%=request.getContextPath()%>/hostel?action=module&name=rooms">
        Rooms
    </a>

    <a href="<%=request.getContextPath()%>/hostel?action=module&name=allocations">
        Room Allocation
    </a>

    <a href="<%=request.getContextPath()%>/hostel?action=module&name=fees">
        Fees
    </a>

    <a href="<%=request.getContextPath()%>/hostel?action=module&name=attendance">
        Attendance
    </a>

    <a href="<%=request.getContextPath()%>/hostel?action=module&name=complaints">
        Complaints
    </a>

    <a class="logout"
       href="<%=request.getContextPath()%>/hostel?action=logout">
        Logout
    </a>

</div>

<div class="main-content">

    <div class="topbar">
        <div>
            <h1><%=title%></h1>
            <p>Manage hostel records</p>
        </div>
    </div>

    <% if (msg != null) { %>
        <div class="alert"><%=esc(msg)%></div>
    <% } %>

    <!-- ADD / UPDATE FORM -->

    <div class="form-card">

        <h2 id="formHeading">Add New Record</h2>

        <form id="recordForm"
              action="<%=request.getContextPath()%>/hostel"
              method="post">

            <input type="hidden" name="action" value="save">

            <input type="hidden"
                   name="module"
                   value="<%=module%>">

            <input type="hidden"
                   name="id"
                   id="recordId"
                   value="">

            <% if ("students".equals(module)) { %>

                <div class="form-grid">

                    <div>
                        <label>Student Name</label>
                        <input type="text" name="name" required>
                    </div>

                    <div>
                        <label>Gender</label>
                        <select name="gender" required>
                            <option value="">Select Gender</option>
                            <option>Male</option>
                            <option>Female</option>
                            <option>Other</option>
                        </select>
                    </div>

                    <div>
                        <label>Phone</label>
                        <input type="text" name="phone">
                    </div>

                    <div>
                        <label>Email</label>
                        <input type="email" name="email">
                    </div>

                    <div>
                        <label>Course</label>
                        <input type="text" name="course">
                    </div>

                    <div>
                        <label>Guardian Name</label>
                        <input type="text" name="guardian_name">
                    </div>

                    <div>
                        <label>Guardian Phone</label>
                        <input type="text" name="guardian_phone">
                    </div>

                    <div>
                        <label>Address</label>
                        <input type="text" name="address">
                    </div>

                </div>

            <% } else if ("rooms".equals(module)) { %>

                <div class="form-grid">

                    <div>
                        <label>Room Number</label>
                        <input type="text" name="room_number" required>
                    </div>

                    <div>
                        <label>Room Type</label>
                        <select name="room_type" required>
                            <option value="">Select Type</option>
                            <option>Single</option>
                            <option>Double</option>
                            <option>Triple</option>
                            <option>Shared</option>
                        </select>
                    </div>

                    <div>
                        <label>Capacity</label>
                        <input type="number" name="capacity" min="1" required>
                    </div>

                    <div>
                        <label>Monthly Fee</label>
                        <input type="number" name="monthly_fee"
                               min="0" step="0.01" required>
                    </div>

                </div>

            <% } else if ("allocations".equals(module)) { %>

                <div class="form-grid">

                    <div>
                        <label>Student ID</label>
                        <input type="number" name="student_id" min="1" required>
                    </div>

                    <div>
                        <label>Room ID</label>
                        <input type="number" name="room_id" min="1" required>
                    </div>

                    <div>
                        <label>Allocation Date</label>
                        <input type="date" name="allocation_date" required>
                    </div>

                    <div>
                        <label>Vacate Date (Optional)</label>
                        <input type="date" name="vacate_date">
                    </div>

                    <div>
                        <label>Status</label>
                        <select name="status">
                            <option>Active</option>
                            <option>Vacated</option>
                        </select>
                    </div>

                </div>

            <% } else if ("fees".equals(module)) { %>

                <div class="form-grid">

                    <div>
                        <label>Student ID</label>
                        <input type="number" name="student_id" min="1" required>
                    </div>

                    <div>
                        <label>Amount</label>
                        <input type="number" name="amount"
                               min="0.01" step="0.01" required>
                    </div>

                    <div>
                        <label>Payment Date</label>
                        <input type="date" name="payment_date" required>
                    </div>

                    <div>
                        <label>Payment Month</label>
                        <input type="text" name="payment_month"
                               placeholder="November 2026">
                    </div>

                    <div>
                        <label>Payment Status</label>
                        <select name="payment_status">
                            <option>Paid</option>
                            <option>Pending</option>
                        </select>
                    </div>

                </div>

            <% } else if ("attendance".equals(module)) { %>

                <div class="form-grid">

                    <div>
                        <label>Student ID</label>
                        <input type="number" name="student_id" min="1" required>
                    </div>

                    <div>
                        <label>Attendance Date</label>
                        <input type="date" name="attendance_date" required>
                    </div>

                    <div>
                        <label>Status</label>
                        <select name="status">
                            <option>Present</option>
                            <option>Absent</option>
                            <option>Leave</option>
                        </select>
                    </div>

                </div>

            <% } else if ("complaints".equals(module)) { %>

                <div class="form-grid">

                    <div>
                        <label>Student ID</label>
                        <input type="number" name="student_id" min="1" required>
                    </div>

                    <div>
                        <label>Complaint Date</label>
                        <input type="date" name="complaint_date" required>
                    </div>

                    <div>
                        <label>Complaint</label>
                        <textarea name="complaint"
                                  maxlength="500"
                                  required></textarea>
                    </div>

                    <div>
                        <label>Status</label>
                        <select name="status">
                            <option>Pending</option>
                            <option>In Progress</option>
                            <option>Resolved</option>
                        </select>
                    </div>

                </div>

            <% } %>

            <div class="form-buttons">

                <button type="submit"
                        class="primary-btn"
                        id="saveButton">
                    Save Record
                </button>

                <button type="button"
                        class="secondary-btn"
                        onclick="clearForm()">
                    Clear Form
                </button>

            </div>

        </form>

    </div>

    <!-- RECORD TABLE -->

    <div class="table-card">

        <h2>All Records</h2>

        <div class="table-wrapper">

            <table>

                <thead>
                    <tr>
                        <% for (String column : columns) { %>
                            <th><%=esc(column)%></th>
                        <% } %>
                        <th>Actions</th>
                    </tr>
                </thead>

                <tbody>

                <% if (rows.isEmpty()) { %>

                    <tr>
                        <td colspan="<%=columns.size()+1%>">
                            No records found.
                        </td>
                    </tr>

                <% } else { %>

                    <% for (Map<String, String> row : rows) { %>

                        <tr data-id="<%=esc(row.get(request.getAttribute("idColumn")))%>">

                            <% for (String column : columns) { %>

                                <td data-col="<%=esc(column)%>"
                                    data-value="<%=esc(row.get(column))%>">

                                    <%=esc(row.get(column))%>

                                </td>

                            <% } %>

                            <td class="action-cell">

                                <button type="button"
                                        class="edit-btn"
                                        onclick="editRow(this)">
                                    Edit
                                </button>

                                <form action="<%=request.getContextPath()%>/hostel"
                                      method="post"
                                      onsubmit="return confirm('Are you sure you want to delete this record?');">

                                    <input type="hidden"
                                           name="action"
                                           value="delete">

                                    <input type="hidden"
                                           name="module"
                                           value="<%=module%>">

                                    <input type="hidden"
                                           name="id"
                                           value="<%=esc(row.get(request.getAttribute("idColumn")))%>">

                                    <button type="submit"
                                            class="delete-btn">
                                        Delete
                                    </button>

                                </form>

                            </td>

                        </tr>

                    <% } %>

                <% } %>

                </tbody>

            </table>

        </div>

    </div>

</div>

</body>
</html>
