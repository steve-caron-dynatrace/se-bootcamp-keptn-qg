@Library('keptn-library')_
def keptn = new sh.keptn.Keptn()

node {
    properties([
        parameters([
         string(defaultValue: "http://<NIP_IO_DOMAIN>:8090", description: 'URL of the application you want to run a test against', name: 'DeploymentURI', trim: false),
         choice(choices: ['Build 1', 'Build 2', 'Build 3'], description: 'Select which build you want to test', name: 'Build', trim: false),
         string(defaultValue: '2', description: 'How long shall we run load against the specified URL?', name: 'LoadTestTime'),
         string(defaultValue: '5000', description: 'Think time in ms (milliseconds) after each test cycle', name: 'ThinkTime'),
         string(defaultValue: '3', description: 'How many minutes to wait after load test is complete until Keptn is done? 0 to not wait', name: 'WaitForResult'),
        ])
    ])

    stage('Initialize Keptn') {
        // keptn.downloadFile("https://raw.githubusercontent.com/keptn-sandbox/performance-testing-as-selfservice-tutorial/master/shipyard.yaml", 'keptn/shipyard.yaml')
        keptn.downloadFile("https://raw.githubusercontent.com/steve-caron-dynatrace/se-bootcamp-keptn-qg/master/3-Jenkins_Integration/dynatrace/dynatrace.conf.yaml", 'keptn/dynatrace/dynatrace.conf.yaml')
        keptn.downloadFile("https://raw.githubusercontent.com/steve-caron-dynatrace/se-bootcamp-keptn-qg/master/3-Jenkins_Integration/slo_perftest.yaml", 'keptn/slo.yaml')
        keptn.downloadFile("https://raw.githubusercontent.com/steve-caron-dynatrace/se-bootcamp-keptn-qg/master/3-Jenkins_Integration/dynatrace/sli_perftest.yaml", 'keptn/sli.yaml')
        archiveArtifacts artifacts:'keptn/**/*.*'

        // Initialize the Keptn Project - ensures the Keptn Project is created with the passed shipyard
        //keptn.keptnInit project:"${params.Project}", service:"${params.Service}", stage:"${params.Stage}", monitoring:"${monitoring}" // , shipyard:'shipyard.yaml'

        keptn.keptnInit project:"jenkins-qg", service:"simplenodeservice", stage:"qualitystage", monitoring:"dynatrace" // , shipyard:'shipyard.yaml'


        // Upload all the files
        keptn.keptnAddResources('keptn/dynatrace/dynatrace.conf.yaml','dynatrace/dynatrace.conf.yaml')
        keptn.keptnAddResources('keptn/sli.yaml','dynatrace/sli.yaml')
        keptn.keptnAddResources('keptn/slo.yaml','slo.yaml')
    }
    stage('Run simple load test') {
        echo "This is really just a very simple 'load simulated'. Dont try this at home :-)" 
        echo "For real testing - please use A REAL load testing tool in your pipeline such us JMeter, Neoload, Gatling ... - but - this is good for this demo"
        
        def URLPaths = ""
        
        switch (params.Build) {
            case "Build 1" : 
                URLPaths = "/,homepage;/api/echo?text=Hello&sleep=500,echo;/api/version,version;/api/invoke?url=https://www.dynatrace.com,invoke";
                break;
            case "Build 2" :
                URLPaths = "/,homepage;/api/echo?text=Hello&sleep=700,echo;/api/version,version;/api/invoke?url=https://www.dynatrace.com,invoke;/api/invoke?url=http://www.keptn.sh,invoke";
                break;
            case "Build 3" :
                URLPaths = "/,homepage;/api/echo?text=Hello&sleep=800,echo;/api/version&sleep=800,version;/api/invoke?url=https://www.dynatrace.com,invoke;/api/invoke?url=https://www.theroar.com.au,invoke";
                break;
            default :
                URLPaths = "/,homepage;/api/echo?text=Hello&sleep=500,echo;/api/version,version;/api/invoke?url=https://www.dynatrace.com,invoke";
                break;
        }
        
        def loadTestTime = params.LoadTestTime?:"3"
        def thinkTime = params.ThinkTime?:2000
        def url = "${params.DeploymentURI}"
        def urlPaths = URLPaths?:"/"
        def urlPathValues = urlPaths.tokenize(';')

        // Before we get started we mark the current timestamp which allows us to run the quality gate later on with exact timestamp info
        keptn.markEvaluationStartTime()

        // now we run the test
        script {
            runTestUntil = java.time.LocalDateTime.now().plusMinutes(loadTestTime.toInteger())
            echo "Lets run a test until: " + runTestUntil.toString()

            while (runTestUntil.compareTo(java.time.LocalDateTime.now()) >= 1) {
                // we loop through every URL that has been passed
                for (i=0;i<urlPathValues.size();i++) {
                    urlPath = urlPathValues[i].tokenize(',')[0]
                    testStepName = urlPathValues[i].tokenize(',')[1]

                    // Sends the request to the URL + Path and also send some x-dynatrace-test HTTP Headers: 
                    // TSN=Test Step Name, LSN=Load Script Name, LTN=Load Test Name
                    // More info: https://www.dynatrace.com/support/help/setup-and-configuration/integrations/third-party-integrations/test-automation-frameworks/dynatrace-and-load-testing-tools-integration/
                    def response = httpRequest customHeaders: [[maskValue: true, name: 'x-dynatrace-test', value: "TSN=${testStepName};LSN=SimpleTest;LTN=simpletest_${BUILD_NUMBER};"]], 
                        httpMode: 'GET', 
                        responseHandle: 'STRING', 
                        url: "${url}${urlPath}", 
                        validResponseCodes: "100:500", 
                        ignoreSslErrors: true
                }

                sleep(time:ThinkTime,unit:"MILLISECONDS")
            }
        }
    }
    stage('Trigger Quality Gate') {
        echo "Quality Gates ONLY: Just triggering an SLI/SLO-based evaluation for the passed timeframe"

        // Trigger an evaluation. It will take the starttime from our call to markEvaluationStartTime and will Now() as endtime
        def keptnContext = keptn.sendStartEvaluationEvent starttime:"", endtime:""
        String keptn_bridge = env.KEPTN_BRIDGE
        echo "Open Keptns Bridge: ${keptn_bridge}/trace/${keptnContext}"
    }
    stage('Wait for Result') {
        waitTime = 0
        if(params.WaitForResult?.isInteger()) {
            waitTime = params.WaitForResult.toInteger()
        }

        if(waitTime > 0) {
            echo "Waiting until Keptn is done and returns the results"
            def result = keptn.waitForEvaluationDoneEvent setBuildResult:true, waitTime:waitTime
            echo "${result}"
        } else {
            echo "Not waiting for results. Please check the Keptns bridge for the details!"
        }

        // Generating the Report so you can access the results directly in Keptns Bridge
        publishHTML(
            target: [
                allowMissing         : false,
                alwaysLinkToLastBuild: false,
                keepAll              : true,
                reportDir            : ".",
                reportFiles          : 'keptn.html',
                reportName           : "Keptn Result in Bridge"
            ]
        )
    }
}
