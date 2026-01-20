package buri.sparkour

import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.http.content.*
import io.ktor.server.plugins.forwardedheaders.*
import io.ktor.server.plugins.statuspages.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.server.thymeleaf.*
import org.slf4j.LoggerFactory
import org.thymeleaf.TemplateEngine
import org.thymeleaf.templateresolver.ClassLoaderTemplateResolver

val recipeTitles = mutableMapOf<String, String>()
val recipeIdPattern = "^[a-zA-Z0-9\\-]+$".toRegex()

/**
 * Launches the KTOR server.
 */
fun main(args: Array<String>) {
    io.ktor.server.netty.EngineMain.main(args)
}

/**
 * Installs plugins and sets up routing.
 */
fun Application.module() {
    val environment = this.environment
    recipeTitles["sparkour-conventions"] = "Tutorial #0: Sparkour Conventions"
    recipeTitles["spark-nutshell"] = "Tutorial #1: Apache Spark in a Nutshell"
    recipeTitles["installing-ec2"] = "Tutorial #2: Installing Spark on Amazon EC2"
    recipeTitles["managing-clusters"] = "Tutorial #3: Managing Spark Clusters"
    recipeTitles["submitting-applications"] = "Tutorial #4: Writing and Submitting a Spark Application"
    recipeTitles["working-rdds"] = "Tutorial #5: Working with Spark Resilient Distributed Datasets (RDDs)"

    recipeTitles["working-dataframes"] = "Working with Spark DataFrames"
    recipeTitles["using-sql-udf"] = "Using SQL and User-Defined Functions with Spark DataFrames"
    recipeTitles["using-jdbc"] = "Using JDBC with Spark DataFrames"
    recipeTitles["controlling-schema"] = "Controlling the Schema of a Spark DataFrame"
    recipeTitles["building-sbt"] = "Building Spark Applications with SBT"
    recipeTitles["building-maven"] = "Building Spark Applications with Maven"
    recipeTitles["broadcast-variables"] = "Improving Spark Performance with Broadcast Variables"
    recipeTitles["aggregating-accumulators"] = "Aggregating Results with Spark Accumulators"
    recipeTitles["understanding-sparksession"] = "Understanding the SparkSession in Spark 2.0"

    recipeTitles["spark-ec2"] = "Managing a Spark Cluster with the spark-ec2 Script"
    recipeTitles["configuring-s3"] = "Configuring Amazon S3 as a Spark Data Source"
    recipeTitles["using-s3"] = "Configuring Spark to Use Amazon S3"
    recipeTitles["s3-vpc-endpoint"] = "Configuring an S3 VPC Endpoint for a Spark Cluster"
    recipeTitles["installing-zeppelin"] = "Installing and Configuring Apache Zeppelin"
    
    install(XForwardedHeaders) {

    }
    install(StatusPages) {
        setup(environment)
    }
    install(Thymeleaf) {
        setup()
    }

    routing {
        staticResources("/robots.txt", "static", index = "robots.txt")
        staticResources("/css", "static.css")
        staticResources("/files", "static.files")
        staticResources("/images", "static.images")
        staticResources("/js", "static.js")

        get("/") {
            val model = environment.buildModel(
                request = call.request,
                title = "Home",
                recipeTitles
            )
            call.respond(ThymeleafContent("home", model))
        }
        get("/license") {
            val model = environment.buildModel(
                request = call.request,
                title = "License",
                recipeTitles
            )
            call.respond(ThymeleafContent("license", model))
        }
        get("/recipes") {
            val model = environment.buildModel(
                request = call.request,
                title = "Recipes",
                recipeTitles
            )
            call.respond(ThymeleafContent("recipes", model))
        }
        get("/recipes/{id}/") {
            val id = call.parameters["id"] ?: ""
            if (!id.matches(recipeIdPattern)) {
                call.respond(HttpStatusCode.NotFound)                
            }
            else {
                val model = environment.buildModel(
                    request = call.request,
                    title = recipeTitles[id] ?: "Untitled",
                    recipeTitles
                )
                model["id"] = id
                model["imagesPath"] = "/recipes/$id"
                call.respond(ThymeleafContent("recipe-$id", model))
            }
        }
    }
}

/**
 * Configuration for Status Pages (404s)
 */
private fun StatusPagesConfig.setup(environment: ApplicationEnvironment) {
    val logger = LoggerFactory.getLogger(this::class.java)

    // 404
    status(HttpStatusCode.NotFound) { call, status ->
        val model = environment.buildModel(
            request = call.request,
            title = "404 Not Found",
            recipeTitles
        )
        call.respond(status, ThymeleafContent("404", model))
    }

    // 500
    exception<Throwable> { call, cause ->
        logger.error(cause.message)
        val model = environment.buildModel(
            request = call.request,
            title = "500 Internal Server Error",
            recipeTitles
        )
        model["message"] = cause.message ?: ""
        model["stackTrace"] = cause.stackTraceToString()
        call.respond(HttpStatusCode.InternalServerError, ThymeleafContent("500", model))
    }
}

/**
 * Configuration for Thymeleaf
 */
private fun TemplateEngine.setup() {
    setTemplateResolver(ClassLoaderTemplateResolver().apply {
        prefix = "views/"
        suffix = ".html"
        characterEncoding = "utf-8"
    })
}

/**
 * Builds a model that controllers can add data to.
 */
fun ApplicationEnvironment.buildModel(request: ApplicationRequest, title: String, recipeTitles: Map<String, String> = mapOf()): MutableMap<String, Any> {
    val baseUrl = this.config.property("sparkour.baseUrl").getString()
    return mutableMapOf(
        // Environment properties.
        "baseUrl" to baseUrl,

        // Head metadata
        "path" to request.path(),
        "title" to title,
        "recipeTitles" to recipeTitles
    )
}