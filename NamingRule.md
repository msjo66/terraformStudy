## [DSpace에 있는 리소스 명명 규칙](https://wiki.dspace.kt.co.kr/pages/viewpage.action?pageId=238572809)

|Azure 리소스 유형|적용 범위|네이밍 규칙|
|------|---|---|
|Management Group|랜딩존 공통적용|\[**매니지먼트그룹명**\]<br> ex) Network|
|Subscriptions|Shared 서비스 종속<br>Workload(단위서비스)종속|**\[구독약어명\]-az01-\[단위서비스코드\]-\[서비스명\]**<br>ex) sub-az01-co013601-azgov<br>**\[구독약어명\]-az01-\[단위서비스코드\]-\[환경\]-\[서비스명\]**<br>ex) sub-az01-co013601-prd-azgov|