<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
<head>
    <title>User Registration</title>
    <link rel="stylesheet" href="style.css" />
    
</head>
<body>
<h2>Register</h2>

<%
    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (username == null || email == null || password == null ||
            username.isEmpty() || email.isEmpty() || password.isEmpty()) {
            message = "Please fill all fields!";
        } else {
            Connection conn = null;
            PreparedStatement pstmt = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                String dbUrl = "jdbc:mysql://localhost:3306/health_fitness_db";
                String dbUser = "root"; // your DB username
                String dbPass = "";     // your DB password

                conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                // Check if username or email exists
                String checkQuery = "SELECT id FROM users WHERE username = ? OR email = ?";
                pstmt = conn.prepareStatement(checkQuery);
                pstmt.setString(1, username);
                pstmt.setString(2, email);
                ResultSet rs = pstmt.executeQuery();

                if (rs.next()) {
                    message = "Username or email already exists!";
                } else {
                    rs.close();
                    pstmt.close();

                    // Insert new user
                    String insertQuery = "INSERT INTO users (username, email, password) VALUES (?, ?, ?)";
                    pstmt = conn.prepareStatement(insertQuery);
                    pstmt.setString(1, username);
                    pstmt.setString(2, email);
                    pstmt.setString(3, password); // For production: hash passwords!

                    int row = pstmt.executeUpdate();
                    if (row > 0) {
                        message = "Registration successful! <a href='login.jsp'>Login here</a>.";
                    } else {
                        message = "Registration failed, try again.";
                    }
                }

                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();

            } catch (Exception e) {
                message = "Error: " + e.getMessage();
            }
        }
    }
%>

<form method="post" action="register.jsp">
    Username:<br/>
    <input type="text" name="username" /><br/>
    Email:<br/>
    <input type="email" name="email" /><br/>
    Password:<br/>
    <input type="password" name="password" /><br/><br/>
    <input type="submit" value="Register" />
</form>

<p style="color:red;"><%= message %></p>

</body>
</html>
