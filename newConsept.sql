--first find top 3 owners then

--stuff fastighetsbeteckning
--stuff namn med samma fastigheter

--STUFF( (   SELECT ',' + CONVERT(NVARCHAR(20), StudentId) FROM Student WHERE condition = abc FOR xml path('') ) , 1 , 1 , '')

--f the StudentId is coming from a non varchar column, you will probably get a conversion exception. You need to use the CONCAT function to do proper concatenation

SELECT StudentID = COALESCE(StudentID + ',', '') + StudentID
FROM Student
WHERE StudentID IS NOT NULL
  and Condition = 'XYZ'
