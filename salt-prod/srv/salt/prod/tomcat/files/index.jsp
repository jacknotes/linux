 <%@ page language="java" %>
 <html>
   <head><title>TomcatA</title></head>
   <body>
     <h1><font color="blue">TomcatA.magedu.com</font></h1>
     <table align="centre" border="1">
       <tr>
         <td>Session ID</td>
     <% session.setAttribute("magedu.com","magedu.com"); %>
         <td><%= session.getId() %></td>
       </tr>
       <tr>
         <td>Created on</td>
         <td><%= session.getCreationTime() %></td>
      </tr>
     </table>
   </body>
 </html>
