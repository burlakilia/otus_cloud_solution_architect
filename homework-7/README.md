**Цель:**
Цель: оценка сервиса(тестирование) с точки зрения принципа “Надежность”


**Описание/Пошаговая инструкция выполнения домашнего задания:**
Инструкция по выполнению задания:
https://wellarchitectedlabs.com/Reliability/300_Testing_for_Resiliency_of_EC2_RDS_and_S3/README.html

**Результат**

После запуска скрипта python3 scripts/fail_instance.py вижу следующее состояние:

- load blanacer (4.2.2): ![img](./results/4.2.2_load_balancing.png)
- auto scaling (4.2.3): ![img](./results/4.2.3_auto_scaling.png)
- RDS-resiliency-testing (5.x) ![img](./results/5_RDS-resiliency-testing.png)
- Test Resiliency Using Application Failure Injection ![img](./results/7_web_servire_fi.png)
- Test Resiliency Using Availability Zone (AZ) Failure Injection ![img](./results/6_failure_injection.png)
