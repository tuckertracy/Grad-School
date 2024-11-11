use Text;

# List the names and manager of the employees of the Marketing department who have a salary 
	# greater than $ 25,000
SELECT E1.empfname as EmpName, E2.empfname as BossName, E1.empsalary
	FROM emp as E1 JOIN emp as E2 ON (E1.bossno=E2.empno)
    WHERE E1.deptname="Marketing" AND E1.empsalary>25000;

# List the departments having an average salary greater than $ 25,000.
SELECT deptname, avg(empsalary)
	FROM emp
    GROUP BY deptname
    HAVING avg(empsalary)>25000;
    
# List the departments having an average BOSS salary greater than $ 25,000.
SELECT E1.deptname, avg(E2.empsalary) as AvgBossSalary
	FROM emp as E1 JOIN emp as E2 ON (E1.bossno=E2.empno)
    GROUP BY E1.deptname
    HAVING AvgBossSalary>25000;

# Find the departments where all the employees earn less than their bosses
SELECT deptname FROM dept
	WHERE deptname NOT IN (
		SELECT distinct E1.deptname
			FROM emp as E1 JOIN emp as E2 ON (E1.bossno=E2.empno)
			WHERE E1.empsalary>E2.empsalary);

# List the departments where the average salary of the employees, excluding the bosses, is greater than $ 25,000
SELECT deptname, avg(E1.empsalary)
	FROM emp as E1
	WHERE NOT EXISTS (SELECT E2.empno FROM emp as E2 WHERE E1.bossno=E2.empno)
    GROUP BY deptname
    HAVING avg(E1.empsalary)>25000;


SELECT deptname, avg(E1.empsalary)
	FROM emp as E1
	WHERE empno NOT IN (SELECT E2.empno FROM emp as E1 JOIN emp as E2 WHERE E1.bossno=E2.empno)
    GROUP BY deptname
    HAVING avg(E1.empsalary)>25000;

SELECT E2.empno
		FROM emp as E1 JOIN emp as E2 ON (E1.bossno=E2.empno);
        
        
select * from emp;