@lab.Title

Login to your VM with the following credentials...

> [!warning] All required credentials are in the **Resources** tab

---

Greetings! This workshop is designed to improve your development experience by:

- Utilizing a personalized remote environment for a quick project kickoff
- Establishing temporary testing environments to evaluate your modifications in line with your company's guidelines
- Employing tools that streamline the process of managing Azure environments and deploying your software
- Harnessing load testing for early identification of potential issues
- Troubleshooting issues in a distributed workload setup

> [!warning] When you started this lab, some provisionning was triggered in background to deploy resources in a dedicated subscription (ie. DevCenter, etc). You don't need to rush as resources may be not be fully deployed if you skip the introduction. It takes roughly 5-7 minutes to deploy everything.

During this workshop, you will receive instructions to complete each step. It is recommended that you search for the answers in the provided resources and links before looking at the solutions placed under the '*Toggle solution*' panel.

> [!note] You will find the instructions and expected configurations for each lab step in these **Task** boxes.
> Inputs and parameters to select will be defined; all the rest can remain at their default settings as they have no impact on the scenario
> Use the provided credentials to log into the Azure subscription locally using Azure CLI and on the [Azure Portal](https://portal.azure.com).
> Instructions and solutions will be provided for *azd*, *Azure CLI*, and the portal, but you can also opt for using the Azure Portal during the entire workshop if you prefer.

## What is Platform Engineering

While people give different definitions to DevOps (a job, automating processes, corporate organisation, mixing Dev And Ops, etc), the Platform engineering is the practice of designing and building toolchains and workflows that enable self-service capabilities for software engineering organizations in the cloud-native era. It focuses on creating a standardized platform that developers can use to build, deploy, and manage applications efficiently. The goal is to reduce complexity, improve developer productivity, and ensure consistency across the development lifecycle.

#### Key aspects of platform engineering include:

- Automation: Automating repetitive tasks to reduce manual intervention.
- Standardization: Creating standardized environments and workflows to ensure consistency.
- Self-Service: Enabling developers to provision and manage their own environments and resources.
- Scalability: Designing platforms that can scale with the needs of the organization.
- Security: Ensuring that security best practices are integrated into the platform.

While both platform engineering and DevOps aim to improve the efficiency and effectiveness of software development and operations, they focus on different aspects and have distinct roles:

**Scope**

- Platform Engineering: Focuses on building and maintaining the underlying infrastructure and tools that developers use to build, deploy, and manage applications. It creates a standardized platform that abstracts away the complexities of the underlying infrastructure.
- DevOps: Focuses on the collaboration between development and operations teams to streamline the software delivery process. It emphasizes practices like continuous integration, continuous delivery, and infrastructure as code.

**Responsibilities**

- Platform Engineers: Responsible for creating and maintaining the platform, ensuring it meets the needs of the development teams, and providing self-service capabilities.
- DevOps Engineers: Responsible for implementing and managing the CI/CD pipelines, automating deployment processes, and ensuring the reliability and scalability of applications in production.

**Goals**

- Platform Engineering: Aims to provide a seamless and efficient development environment that reduces friction and increases developer productivity.
- DevOps: Aims to improve collaboration between development and operations, reduce the time to market, and ensure the stability and reliability of applications.

In summary, platform engineering focuses on building the tools and infrastructure that developers use, while DevOps focuses on the processes and practices that enable efficient software delivery and operations. Both are essential for modern software development but address different challenges within the organization.

## Microsoft vision

!IMAGE[plateng2.png](instructions281629/plateng2.png)

As you embark on your own platform engineering journey with Microsoft, you'll likely encounter three key motions:

- "**Start Right**" focuses on equipping your developers with self-service tools, enabling them to kickstart their projects quickly while adhering to your company's best practices defined through templates and policies.
- "**Stay Right**" is all about maintaining compliance as your projects grow and ensuring that developers continue to follow those best practices via continous automation and monitoring.
- Finally, "**Get Right**" campaigns assist developers in bringing their existing DevOps infrastructure, code, and applications into compliance within your company's evolving standards.  

But the best compliance work feels "free“ to the developer - it's automated, invisible, and so ingrained in tools and processes that much of it is embedded." 

To answer these three motions, the company needs to set up a platform with a toolbox composed of several products:

!IMAGE[plateng1.png](instructions281629/plateng1.png)

As Microsoft, we offer n product for each of these components

!IMAGE[plateng3.png](instructions281629/plateng3.png)

## Scenario

We can't cover all these products in one lab, so we'll focus on some of them that have great traction with our customers.

The goal of the workshop is to edit the code of a simple *Order Management* API, deploy it to Azure, and detect potential issues using load tests and monitoring.

We will be using the following services:

- [Microsoft Dev Box][devbox]
- [Azure Deployment Environment][ade]
- [Azure Developer CLI][azd]
- [Azure Load Testing][loadtesting]
- [Application Insights][appinsights]

!IMAGE[global-diagram.png](instructions281629/global-diagram.png)

[az-portal]: https://portal.azure.com
[devbox]: https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box
[ade]: https://learn.microsoft.com/en-us/azure/deployment-environments/overview-what-is-azure-deployment-environments
[azd]: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview
[loadtesting]: https://learn.microsoft.com/en-us/azure/load-testing/overview-what-is-azure-load-testing
[appinsights]: https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview
[devportal]: https://devportal.microsoft.com/
[functionloadtesting]: https://learn.microsoft.com/en-us/azure/load-testing/how-to-create-load-test-function-app
[applicationmap]: https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-map

===

# Lab 1 : Make changes to the project

[devportal]: https://devportal.microsoft.com/
[vscode]: https://code.visualstudio.com/
[azure]: https://portal.azure.com/

## Setup your dev environment

Azure DevBox is a development environment provided by Microsoft Azure. It's essentially a cloud-based, pre-configured development environment that developers can use to write, run, and debug their code. Here are some of its advantages:

- **Pre-configured Environment**: Azure DevBox comes with a pre-configured development environment, which includes a variety of popular programming languages, development tools, and frameworks. This saves developers the time and effort of setting up their own environment.
- **Anywhere Access**: Since Azure DevBox is cloud-based, developers can access their development environment from anywhere, on any device. This makes it a great tool for remote teams and flexible working arrangements.
- **Scalability**: Azure DevBox can easily scale up or down based on the needs of the project. This means developers can choose the right amount of resources for their project, without having to worry about over or under-provisioning.
- **Integration with Azure Services**: Azure DevBox is fully integrated with other Azure services, making it easy to build, test, and deploy applications that use these services.
- **Security**: Azure DevBox is hosted on Azure, which means it benefits from Azure's security measures. This includes features like Azure Security Center, Azure Active Directory, and compliance offerings.
- **Collaboration**: Azure DevBox supports real-time collaboration between developers. This makes it easier for teams to work together on the same codebase, regardless of their physical location.

We will be using a Dev Box with a customized image intended for full stack development. The Dev Box includes [VS Code][vscode] with a few extensions such as Node.js, git, Azure CLI, and azd.

> [!note] **Task**
> 
> - Log into the Azure portal
> - Find the DevCenter and check the projet and its configuration

>[+] *Toggle Solution*
> 
> 1. Open the [Azure portal][azureportal]
> 1. Sign in using the provided credentials (**see Resources tab**)
> 1. Look for the resource group named **rg-plateng**
> 1. Open the DevCenter resource
> 1. As you can see, a project has been created, with pools and devbox definitions. That's the one you are going to be able to use
> !IMAGE[devcenter-project.png](instructions281629/devcenter-project.png)
> 1. At the devcenter level (not project!), a catalog has been created. Click on it, it contains environment definitions (*Infra as Code*) that users can use and deploy on demand
> !IMAGE[devcenter-catalog.png](instructions281629/devcenter-catalog.png)

> [!note] **Task**
> 
> - Log into the Developer portal and connect to your Dev Box
> - Open VS Code

>[+] *Toggle Solution*
> 
> 1. Open the [Developer portal][devportal]
> 1. Sign in using the provided credentials (**see Resources tab**).
> 1. Ask for a new DevBox, you can choose between 2 VMs profiles (**WebDevPool** and **WebDevPoolPowerful**)
> !IMAGE[devportal.png](instructions281629/devportal.png)
> !IMAGE[devportal2.png](instructions281629/devportal2.png)
> 1. If you want to can use customizations. It means loaded a YAML file containing the customization you want to apply to your devbox on startup.
> 1. !IMAGE[devportal3.png](instructions281629/devportal3.png)
> 1. Once the Dev Box is created, click on the __Connect__ button
> 1. Wait until the Dev Box starts
> 1. Open VS Code
> 1. Check the installed extensions, you should be able to see Azure and GitHub extensions (among others)

> [!warning]
> An Azure DevBox provisionning can take up to **one hour** due to Intune enrollment. The product group is working to reduce this time in the upcoming months. Since the your time in this classroom is limited, please use the lab's VM instead, it will act as your "DevBox" as requirements have been installed on it too (NodeJS, VSCode, AZD, etc.). The creation you just did was to understand the user experience developers would have in real life.

## Clone the project

> [!note] **Task**
> 
> On your **desktop**, clone the project [https://github.com/ikhemissi/hands-on-lab-platform-engineering-for-devs](https://github.com/ikhemissi/hands-on-lab-platform-engineering-for-devs)
> Place your command line inside this new folder.


>[+] *Toggle Solution*
>
> Use the integrated terminal to run the following commands:
> 
> ```sh
> git clone https://github.com/ikhemissi/hands-on-lab-platform-engineering-for-devs.git
> ```


## Update the code

> [!note] **Task**
> 
> Update the *qna* endpoint in *servicess/api/src/api.js* by prefixing the return value with a prefix of your choice



>[+] *Toggle Solution*
>
> 1. Open the file **services/api/src/api.js**
> 1. Locate the line **answer: '42'**,
> 1. Replace **'42'** with **'PREFIX 42'** where **PREFIX** is your initials

===

# Lab 2 : Deploy your code to Azure

[resourcemanager]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview
[ade]: https://learn.microsoft.com/en-us/azure/deployment-environments/overview-what-is-azure-deployment-environments
[azd]: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview


In this second lab we will focus on how to deploy our services to Azure.

To do this we need to:

- Provision resources on Azure like the compute services which will host our code, the database, and the monitoring service
- Package our code and deploy it to the provisioned resources

## Provision resources on Azure

Resource provisioning can be done [in many ways][resourcemanager]:

- (Recommended) Using *Infrastructure as Code* (IaC) like Bicep or Terraform
- Using the Azure CLI
- Using APIs and SDKs
- From the Azure Portal

Working with IaC can be a challenge in some contexts like defining who can do what:

- Who will be writing the IaC and guaranteeing it is compliant with company standards and best practices ?
- Who will be creating resources using IaC, and how ? (i.e. Who needs enough rights on Azure to provision them? How be agile ?)

[Azure Deployment Environments][ade] solves this problems by providing a framework for authoring "environment definitions", provisioning them, assigning resources to projects, and handling permissions.
Environments can be created directly from the [Developer portal][devportal] or using a compatible tool like Azure Developer CLI (`azd`).

> [!note] **Task**
> 
> Create a new environment using the **Function** definition

>[+] *Toggle Solution*
>
> 1. Open the [Developer portal][devportal]
> 1. Sign in using the provided credentials if needed
> 1. Click on the **New** button on the top left and click on the **New environment** option. Copy the chosen name.
> 1. Choose a short name and select **Project-1**
> 1. Select the environment type **Dev** and the **Function** definition
> !IMAGE[devcenter-ade.png](instructions281629/devcenter-ade.png)
> 1. Hit **Next**
> 1. Use the same environment name as in the previous step and leave the location as is.
> 1. Hit **Create** and wait for the environment to be created (could take few minutes)
> !IMAGE[devcenter-ade-creation.png](instructions281629/devcenter-ade-creation.png)

## Deploy services

[*azd*][azd] simplifies the process of creating resources and deploying code by providing a simple abstraction on top of the various integrations (e.g. with compute and management services).

> [!note] **Task**
> 
> - Using [*azd*][azd], select the ADE environment which you have previously created
> - Deploy your applications (azd services) to the selected environment

> [!warning] 
> Be sure that your command line current folder is the one you just cloned. You must be inside the cloned folder, not the parent.

>[+] *Toggle Solution*
>
>1. Enable Dev Center integration
>
>```sh
>azd config set platform.type devcenter
>```
>
>2. Log into Azure using **azd**
>
>```sh
>azd auth login
>```
>
>3. List available environments using **env list**
>
>```sh
>azd env list
>```
>
>4. Select the remote environment which was created via Dev portal
>
>```sh
>azd env select <ade-environment-name>
>```
>
>5. Deploy services to the selected environment using the configuration defined in **azure.yaml**
>
>```sh
>azd deploy
>```
> !IMAGE[azd-deploy.png](instructions281629/azd-deploy.png)

Follow the wizard and wait until the deployment finishes.
You should have access to the deployed service url (e.g. Function App) and the resource group which was used for the deployment.

## Test deployed services

> [!note] **Task**
> 
> Test the newly deployed function and make sure the changes you made in the last step of Lab n°1 are being taken into account in the response of the function.

> [!hint] **Tip**
> 
> You can use the supplied *test.http* file to test the newly deployed function

>[+] *Toggle Solution*
>
> 1. Open the **test.http**
> 1. Update the **@host** variable to point to your Function App
> 1. Use the **Send Request** button on top of line 3 to send a request. It comes from the extension **REST Client (by Huachao Mao)**, normally already installed on your VS Code
> !IMAGE[request.png](instructions281629/request.png)
> 1. Make sure you see the change you made at the end of Lab 1 (e.g. adding a prefix to the response)

===

# Lab 3 : Load testing

## Create a load test

Using load testing can help identify potential issues (e.g. errors and latency) very early and reduce the impact of these issues on your users.

Azure Load Testing is a cloud-based service provided by Microsoft Azure that allows developers to simulate high volumes of user traffic to their applications. This service is designed to identify potential performance bottlenecks and ensure that applications can handle high loads, especially during peak times.

Benefits of Azure Load Testing:

- **Scalability**: Azure Load Testing can simulate thousands to millions of virtual users, allowing you to test your application under various load conditions.
- **Ease of Use**: With its intuitive interface and pre-configured test templates, Azure Load Testing makes it easy to set up and run load tests.
- **Detailed Reporting**: Azure Load Testing provides detailed reports and real-time analytics, helping you identify and resolve performance bottlenecks.
- **Cost-Effective**: With Azure Load Testing, you only pay for what you use. This makes it a cost-effective solution for load testing.

Integration with other services:

Azure Load Testing integrates seamlessly with other Azure services. For instance, it can be used in conjunction with Azure Monitor and Application Insights to provide detailed performance metrics and insights. It also integrates with Azure DevOps, allowing you to incorporate load testing into your CI/CD pipeline.

## Run the test

> [!note] **Task**
> 
> - Create a Load test for the `Function` endpoint
> - Limit the duration of the test to **3 minutes**

> [!hint] **Tip**
> 
> Use the direct integration of [Azure Load Testing with Azure Functions][functionloadtesting]


>[+] *Toggle Solution*
>
> 1. Locate the Function App in the Azure Portal
> 1. Click on the **Load Testing (Preview)** blade
> 1. Click on the **Create test** button
> 1. Select the existing Azure Load Testing resource and provide a short name and description of the test
> 1. Click on **Add request**
> 1. Make sure the pre-populated request points to your Function endpoint and uses the right HTTP method (**POST**)
> 1. Select the body tab, set the **Data type** value to **JSON view**, and paste the request body used in the file **test.http**
> 1. Valide the request using the **Add** button
> 1. Select the tab **Load configuration** and set **Test duration (minutes)** to 3
> 1. Click on **Review + create** then on **Create**
> 1. The test will take few seconds to get created and then you should see a popup telling you that the test has started


As the test starts, you will see a **Load test results** dashboard with various metrics like the total number of requests, throughput, and error percentage.

> [!note] **Task**
> 
> - Find out the average response time ?

>[+] *Toggle Solution*
>
> 1. Locate the **Aggregation** filter in the **Client-side metrics** panel
> 1. Uncheck existing selection, select **Average**, then click on **Apply**
> 1. Locate the metric below the graph in **Response time (successful responses)**. That is the average response time.

## Check your stack using Application Map

Application Insights is a feature of Azure Monitor and is a service provided by Microsoft Azure that helps developers monitor the performance and usage of their live web applications. It automatically collects telemetry data, provides analytical tools, and helps diagnose issues and understand what users actually do with your app.

Key features of Application Insights include:

- **Performance Monitoring**: It provides real-time insights into your application's performance and identifies any bottlenecks.
- **Usage Analytics**: It tracks how users are interacting with your application and identifies any trends or patterns.
- **Application Dependency Mapping**: It visualizes the components of your application and their interactions, helping you understand the impact of any changes or failures.
- **Exception Tracking**: It captures and analyzes exceptions in your application, helping you diagnose and fix issues faster.

The Application Map is a feature within Application Insights that provides a visual overview of the components of your application and their interactions. It shows the flow of requests across these components and helps identify any failures or performance bottlenecks. This makes it easier to understand the architecture of your application and diagnose any issues.

!IMAGE[application-map.png](instructions281629/application-map.png)

> [!note] **Task**
> 
> - Find out how what components are used within your stack/workload
> - Which component depends on the other ?
> - Where is most of the time spent when making a request to your function ?

</div>

> [!hint] **Tip**
> 
> Check the [Application Map overview][applicationmap]

>[+] *Toggle Solution*
>
> 1. Open the resource group on Azure portal
> 1. Locate the Application Insights resource
> 1. Click on the **Application Map** blade
> 1. You should see the various component of the stack and their dependencies
> 1. Check the average duration spent on each component and locate the one where most of the time is spent

===

# Lab 4 : Investigate errors

As you add new features to your application, few regressions may appear, hence the need for testing and monitoring to detect and fix these regressions.

To simulate making changes and deploying new releases, the provided Function App relies on the **RELEASE** environment variable to control its behavior and introduce regressions like throwing errors and injecting latency.

## Simulate a new release

> [!note] **Task**
> 
> - Update the config of the Function Apps by setting the environment variable **RELEASE** to **2**. The function should start throwing errors for 10% of the requests.

>[+] *Toggle Solution*
>
> 1. Open the resource group on Azure portal
> 1. Locate the Function App
> 1. Click on the **Environment variables** blade
> 1. Click on the **RELEASE** environment variable to edit it
> 1. Set the value to **2** and hit **Apply**
> 1. Hit **Apply** to validate all changes on environment variables
> 1. Select **Confirm**

The Function App will reload and then it will adapt its behavior to throw errors at a 10% rate


## Re-run load testing

> [!note] **Task**
> 
> - Re-run the load test which you have created in the previous lab and observe if there are any changes compared to before

>[+] *Toggle Solution*
>
> You can either opt for creating a new test like you did in Lab 3 or re-rerun an existing test.
> Here is how you should proceed if you choose to rerun a test:
> 1. Locate the Function App in the Azure Portal
> 1. Click on the **Load Testing (Preview)** blade
> 1. Select any test in **Test runs** section
> 1. Click on the **Rerun** button on the top
> 1. Optionally provide a short description (e.g. **Checking for errors**)
> 1. Click on the **Rerun** button
> 1. The test will take few seconds to get created and then you should see a popup telling you that the test has started
> 1. Click on the new test run to access test results

## Inspect errors

> [!note] **Task**
> 
> - Use Application Insights to find more details about the error that you started observing.
> - Which service and which line of code is throwing this error ?


>[+] *Toggle Solution*
>
> 1. Open the resource group on Azure portal
> 1. Locate the Application Insights resource
> 1. You should see a spike of errors on the **Failed requests** panel
> 1. Use the **Failures** blade or click on the errors' chart
> 1. Click on the top response code (**500**) on the right panel
> 1. Select the suggested sample operation on the right panel
> 1. You should see the details of the errors including any other service which was involved on the operation
> 1. Click on **Traces and Events**
> 1. Select the exception to access its call stack
> 1. Check the **message** on the right panel and click on **[show more]** to get more details
> 1. You should see a reference to **Random error**, the file **api.js** where the error was triggered, and the call trace including line numbers

</details>

===

# Lab 5 : Investigate latency issues

The goal of this lab is to investigate potential latency issues.
The release **3** introduces a latency of 2 seconds in the function, so you will start by simulating the deployment of that release.

> [!note] **Task**
> 
> - Update the config of the Function Apps by setting the environment variable **RELEASE** to *3*. Request should now be 2 seconds slower compared to before.


>[+] *Toggle Solution*
>
> 1. Open the resource group on Azure portal
> 1. Locate the Function App
> 1. Click on the **Environment variables** blade
> 1. Click on the **RELEASE** environment variable to edit it
> 1. Set the value to **3** and hit **Apply**
> 1. Hit **Apply** to validate all changes on environment variables
> 1. Select **Confirm**
> 
> The Function App will reload and then it will adapt its behavior to inject a latency of 2 seconds


## Run load testing again

> [!note] **Task**
> 
> - Re-run the same load test which you have used in the previous lab and observe if there are any changes compared to before

>[+] *Toggle Solution*
>
> You can either opt for creating a new test like you did in Lab 3 or re-rerun an existing test.
> 
> Here is how you should proceed if you choose to rerun a test:
> 
> 1. Locate the Function App in the Azure Portal
> 1. Click on the **Load Testing (Preview)** blade
> 1. Select any test in **Test runs** section
> 1. Click on the **Rerun** button on the top
> 1. Optionally provide a short description (e.g. **Checking for latency issues**)
> 1. Click on the **Rerun** button
> 1. The test will take few seconds to get created and then you should see a popup telling you that the test has started
> 1. Click on the new test run to access test results

## Inspect performance issues

> [!note] **Task**
> 
> - Use Application Insights to find more details about the latency issue that you started observing.

>[+] *Toggle Solution*
>
> 1. Open the resource group on Azure portal
> 1. Locate the Application Insights resource
> 1. You should see an increase in response time on the **Server response time** panel
> 1. Use the **Performance** blade or click on the response time chart
> 1. You should see the duration taken by each operation
> 1. The **qna** operation should be unnaturally slow (+2 seconds) and you should see a red arrow on the right of the operation together with the percentage of increase in latency. That is the endpoint to investigate.
> 1. You can use the **Profiler** to get more details about the origin of the issue

The Profiler in Application Insights is a powerful feature that allows developers to collect detailed performance data from a live web application. It's essentially a diagnostic tool that helps you understand the performance characteristics of your application and find the root cause of any performance issues.

Here are some key details about the Profiler:

- **Performance Tracing**: The Profiler can collect detailed traces of your application's performance, including the time taken by each operation. This can help you identify any bottlenecks or slow operations in your application.
- **Code-Level Insights**: The Profiler can provide insights at the level of individual lines of code. This means you can see exactly which parts of your code are causing performance issues.
- **Low Overhead**: The Profiler is designed to have a low overhead, so it won't significantly impact the performance of your application. This means you can use it in a live environment without worrying about affecting your users.
- **Integration with Application Insights**: The Profiler is fully integrated with Application Insights, so you can correlate performance data with other telemetry data collected by Application Insights. This can give you a more complete picture of your application's performance.
- **Triggered Profiling**: You can configure the Profiler to automatically start collecting data when certain conditions are met, such as a specific performance threshold being exceeded. This can help you catch intermittent performance issues that might be hard to reproduce.

If you want more information about the profiler, please follow this [guide](https://learn.microsoft.com/en-us/azure/azure-monitor/profiler/profiler-overview)
