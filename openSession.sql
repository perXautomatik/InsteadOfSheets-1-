--opening session
DECLARE @cookie VARBINARY(8000);
EXECUTE AS USER = 'ADM\CRBK01' WITH COOKIE INTO @cookie;
-- Store the cookie in a safe location in your application.
-- Verify the context switch.
SELECT SUSER_NAME(), USER_NAME();
--Display the cookie value.
SELECT @cookie 'col1' into cookie;
GO