
<%@ page contentType="text/html;charset=UTF-8" %>

<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect(request.getContextPath() + "/hostel");
        return;
    }

    String msg = (String) session.getAttribute("message");
    session.removeAttribute("message");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Hostel Management Dashboard</title>

    <link rel="stylesheet"
          href="<%=request.getContextPath()%>/css/style.css">
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
        Fee Management
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
            <h1>Dashboard</h1>
            <p>Welcome to Hostel Management System</p>
        </div>

        <div class="admin-label">
            Admin: <%=session.getAttribute("admin")%>
        </div>
    </div>

    <% if (msg != null) { %>
        <div class="alert"><%=msg%></div>
    <% } %>

    <div class="card-container">

        <div class="stat-card blue">
            <h3>Total Students</h3>
            <h1><%=request.getAttribute("students")%></h1>
            <p>Registered students</p>
        </div>

        <div class="stat-card green">
            <h3>Total Rooms</h3>
            <h1><%=request.getAttribute("rooms")%></h1>
            <p>Available room records</p>
        </div>

        <div class="stat-card orange">
            <h3>Active Allocations</h3>
            <h1><%=request.getAttribute("allocations")%></h1>
            <p>Currently allocated</p>
        </div>

        <div class="stat-card purple">
            <h3>Total Fees Collected</h3>
            <h1>₹<%=request.getAttribute("fees")%></h1>
            <p>Paid fee records</p>
        </div>

    </div>

    <div class="welcome-card">
        <h2>Hostel Administration</h2>

        <p>
            Manage students, rooms, room allocations, fees,
            attendance and complaints from one place.
        </p>

        <h3>Quick Actions</h3>

        <div class="quick-actions">

            <a href="<%=request.getContextPath()%>/hostel?action=module&name=students">
                Manage Students
            </a>

            <a href="<%=request.getContextPath()%>/hostel?action=module&name=rooms">
                Manage Rooms
            </a>

            <a href="<%=request.getContextPath()%>/hostel?action=module&name=fees">
                Manage Fees
            </a>

        </div>
    </div>

</div>

</body>
</html>
