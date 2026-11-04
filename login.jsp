
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String msg = (String) session.getAttribute("message");
    session.removeAttribute("message");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Hostel Management - Admin Login</title>
    <link rel="stylesheet"
          href="<%=request.getContextPath()%>/css/style.css">
</head>

<body class="login-body">

<div class="login-container">

    <div class="login-icon">🏨</div>

    <h1>Hostel Management</h1>
    <p class="subtitle">Admin Login Portal</p>

    <% if (msg != null) { %>
        <div class="alert"><%=msg%></div>
    <% } %>

    <form action="<%=request.getContextPath()%>/hostel"
          method="post">

        <input type="hidden" name="action" value="login">

        <label>Username</label>
        <input type="text"
               name="username"
               placeholder="Enter username"
               required>

        <label>Password</label>
        <input type="password"
               name="password"
               placeholder="Enter password"
               required>

        <button type="submit" class="primary-btn">
            Login
        </button>

    </form>

    <p class="login-footer">
        Hostel Management System © 2026
    </p>

</div>

</body>
</html>
