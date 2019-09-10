Query 1: --What are the request id, department name, request date, product id, product name, required delivery date, request status, urgency, quantity ordered and quantity in stocks of products that are, requested by the employee but, currently unavailable in the stocks and have request status as pending?
--Data is listed on the basis of request_date , urgency and required_delivery_date
select r.request_id,d.DEPARTMENT_name,r.request_date,p.product_id,p.product_name,r.required_delivery_date,r.request_status,r.urgency,
r.quantity quantity_ordered,p.quantity_instock
from request r
inner join product p on r.product_id=p.product_id
inner join employee e on e.employee_id=r.employee_id
inner join department d on d.department_id=e.DEPARTMENT_ID
where r.request_status='Pending' and p.quantity_instock<=r.QUANTITY
order by r.request_date,r.urgency, r.required_delivery_date;
Query 2: --What are the department id, department name, product name, total quantities of the product requested by each department in current year and has request status complete?
select d.department_id,d.DEPARTMENT_name,p.product_name,sum(r.quantity) total_quantity
from request r
inner join product p on r.product_id=p.product_id
inner join employee e on e.employee_id=r.employee_id
inner join department d on d.department_id=e.DEPARTMENT_ID
where r.request_status='Completed' and year(r.request_date)=year(cast(getdate() as date))
and r.request_date<=cast(getdate() as date)
group by d.department_id,d.DEPARTMENT_name,p.product_name
order by d.DEPARTMENT_name;
Query 3:
--
Update request status of the product to complete after successful fulfillment of its request
update request set REQUEST_STATUS='Completed' where request_id = 'R000000006';
update request set REQUEST_STATUS='Completed' where request_id = 'R000000005';
Query 4: --What are the supplier details, product id and product name of the products purchased from the supplier?
select s.supplier_id,s.supplier_name, pr.product_id ,pr.product_name,
s.contact_no supplier_contact_no,s.email_id supplier_email_id,
s.avg_delivery_time supplier_avg_delivery_time,s.address supplier_address,s.rating suplier_rating
from purchase p
inner join supplier s on p.supplier_id=s.supplier_id
inner join purchase_item i on p.purchase_id=i.purchase_id
inner join product pr on pr.product_id=i.product_id
order by s.supplier_name,pr.product_name;
Query 5: What are supplier name, supplier rating, supplier average delivery time, product id, product name, quantity purchase of all products supplied by supplier that had highest rating w.r.t purchases made in previous month?
select s.supplier_id,s.supplier_name,s.rating supplier_rating,s.avg_delivery_time supplier_avg_delivery_time,
pr.product_id,pr.product_name,sum(i.quantity) quantity_purchased
from purchase p
inner join supplier s on p.supplier_id=s.supplier_id
inner join
(select distinct s.supplier_id
from purchase p
inner join supplier s on p.supplier_id=s.supplier_id
where month(p.purchase_request_date)=month(cast(getdate() as date))-1 and s.rating>=4 and p.purchase_status='Completed'
) a on s.supplier_id=a.supplier_id
inner join purchase_item i on i.purchase_id=p.purchase_id
inner join product pr on pr.product_id=i.product_id
where year(p.purchase_request_date)=year(cast(getdate() as date)) and p.purchase_status='Completed'
group by s.supplier_id,s.supplier_name,s.rating,s.avg_delivery_time,
pr.product_id,pr.product_name;
Query 6 --What are the employee id, employee name, product id, product name and quantities of the products requested by a particular employee ?
select e.employee_id,e.firstname+' '+e.lastname employee_name,r.product_id,p.product_name,r.quantity request_quantity
from employee e
inner join request r on e.employee_id=r.EMPLOYEE_ID
inner join product p on p.product_id=r.product_id
where e.employee_id='E082123411'
order by product_id;
Query 7: --Update the budget after the purchase order request for the product has been placed.
update BUDGET set BUDGET_USED=BUDGET_USED-a.amount
from (
select sum(i.quantity*i.unit_retail_price) amount,p.budget_id
from purchase p
inner join purchase_item i on i.purchase_id=p.purchase_id where p.purchase_id='PR00000007'
group by p.budget_id
) a
where BUDGET.BUDGET_ID=a.BUDGET_ID;
Query 8: --What is the budget utilization of previous month?
select sum(i.quantity*i.unit_retail_price) amount,p.budget_id ,datename(month,p.purchase_request_date) month,
datename(year,p.purchase_request_date) year
from purchase p
inner join purchase_item i on i.purchase_id=p.purchase_id
where month(p.purchase_request_date)=month(cast(getdate() as date))-1
group by p.budget_id ,datename(month,p.purchase_request_date),datename(year,p.purchase_request_date);
Query 9: --What are the supplier id, supplier name , delivery time, supplier ratings product name and unit retail price of out of stock products that are being purchased from the supplier?
select distinct pr.product_id,pr.product_name,i.unit_retail_price,p.supplier_id,s.supplier_name,
s.avg_delivery_time,s.rating,s.address
from product pr
inner join purchase_item i on i.product_id=pr.product_id
inner join purchase p on p.purchase_id=i.purchase_id
inner join supplier s on s.supplier_id=p.supplier_id
where pr.quantity_instock=0
order by pr.product_name,i.unit_retail_price,s.supplier_name;
Query 10: --What are the employee id, employee name, category id, category name, product id, product name, quantities of product wished by employee, in stock quantity of the products currently
present in the wishlist of employee for prior evaluation of future product requirement in order to expedite the process of fulfillment ?
select e.EMPLOYEE_ID,e.FIRSTNAME+' '+e.LASTNAME Employee_name,c.category_id,c.category_name,
w.PRODUCT_ID,p.product_name,w.QUANTITY product_quantiity_wished,p.quantity_instock product_quantity_instock
from WISHLIST w
inner join product p on p.product_id=w.product_id
inner join category c on c.category_id=p.category_id
inner join EMPLOYEE e on e.EMPLOYEE_ID=w.EMPLOYEE_ID
inner join DEPARTMENT d on d.DEPARTMENT_ID=e.DEPARTMENT_ID
order by e.FIRSTNAME+' '+e.LASTNAME,c.category_name,p.product_name;