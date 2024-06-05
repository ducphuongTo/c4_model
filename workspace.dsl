workspace {

    model {
        # People/Actors
        # <variable> = person <name> <description> <tag>
        publicUser = person "Public User" "A user of the book store, who can get book details, without personal bookstore accounts." "User"
        authorizedUser = person "Authorized User" "A user of the book store, who can search book records and administer book details, with personal bookstore accounts." "User"

        # Level 1: Context Diagram for Books Store System
        # Software System
        # <variable> = softwareSystem <name> <description> <tag>
        bookStoreSystem = softwareSystem "Book Store System" "Books Store System allows users to get, search book records and administering book details" "Target System" {
            # Level 2: Container Diagram for Books Store System
            searchWebApi = container "Search Web API" "Provides book search functionality via a JSON/HTTPS API." "Go" "Web API"
            publicWebApi = container "Public Web API" "Provides book details functionality via a JSON/HTTPS API." "Go" "Web API"
            bookKafkaSystem = container "Book Kafka System" "Handles book-related domain events." "Apache Kafka 3.0" "Kafka System"
            elasticSearchEventConsumer = container "ElasticSearch Event Consumer" "Consumes events and updates the search index." "Go" "Event Consumer"
            searchDatabase = container "Search Database" "Stores searchable books details." "ElasticSearch" "Database"
            relationalDatabase = container "Read/Write Relational Database" "Stores books details." "PostgreSQL" "Database"
            readerCache = container "Reader Cache" "Caches books details." "Memcached" "Cache"
            publisherRecurrentUpdater = container "Publisher Recurrent Updater" "Listening to external events coming from Publisher System." "Kafka" "Recurrent Updater"
            adminWebApi = container "Admin Web API" "Provides book administration functionality via a JSON/HTTPS API." "Go" "Web API" {
                # Level 3: Component Diagram
                bookService = component "service.Book" "Allows administering book details." "Go"
                authorizerService = component "service.Authorizer" "Allows authorizing books details." "Go"
                eventsPublisherService = component "service.EventsPublisher" "Allows publishing books-related events." "Go"
            }
        }

        # External Software Systems
        externalAuthorizeSystem = softwareSystem "External Authorize System" "An external Authorization System for authorization purposes" "External System"
        externalPublisherSystem = softwareSystem "External Publisher System" "An external Publisher System for giving details about books published" "External System"

        # Relationship between People/Actor and Software Systems
        publicUser -> bookStoreSystem "Gets book details"
        authorizedUser -> bookStoreSystem "Searchs book records and administers book details"
        bookStoreSystem -> externalAuthorizeSystem "Authorizes users using"
        bookStoreSystem -> externalPublisherSystem "Gets book details about books published using"

        # Relationship between Containers
        authorizedUser -> searchWebApi "Searching book records via" "JSON/HTTPS"
        searchWebApi -> externalAuthorizeSystem "Authorizes users using" "JWT"
        searchWebApi -> searchDatabase "Searching read-only records from" "JDBC"

        authorizedUser -> adminWebApi "Administering book details via" "JSON/HTTPS"
        adminWebApi -> externalAuthorizeSystem "Authorizes users using" "JWT"
        adminWebApi -> relationalDatabase "Read data from and write data to" "JDBC"
        adminWebApi -> bookKafkaSystem "Publishes events to" "Uses Kafka Producer" {
            tags "Async Request"
        }

        publicUser -> publicWebApi "Getting book details via" "JSON/HTTPS"
        publicWebApi -> relationalDatabase "Reads data from" "JDBC"
        publicWebApi -> readerCache "Reads/write data to" "Uses Memcached client"

        elasticSearchEventConsumer -> bookKafkaSystem "Listening to" "Uses Kafka Consumer" {
            tags "Async Request"
        }
        elasticSearchEventConsumer -> searchDatabase "Updating publisher by writing publisher to" "JDBC"

        publisherRecurrentUpdater -> externalPublisherSystem "Listening to external events coming from" "Kafka Consumer" {
            tags "Async Request"
        }
        publisherRecurrentUpdater -> relationalDatabase "Updates the Read/Write Relational Database with detail from Publisher system" "JDBC"
        publisherRecurrentUpdater -> adminWebApi "Updating data via" "JSON/HTTPS"

        # Relationship between Containers and External Systems
        authorizedUser -> bookService "Administering book details via" "JSON/HTTPS"
        authorizerService -> externalAuthorizeSystem "Authorizes users using"
        eventsPublisherService -> bookKafkaSystem "Publishes books-related domain events to"
        bookService -> relationalDatabase "Read from and write data to"
        bookService -> authorizerService "Calls"
        bookService -> eventsPublisherService "Calls" {
            tags "Async Request"
        }
    }

    views {
        # Level 1: Context Diagram for Books Store System
        systemContext bookStoreSystem "SystemContext" {
            include *
            autoLayout
        }
        # Level 2
        container bookStoreSystem "Containers" {
            include *
            autoLayout
        }
        # Level 3
        component adminWebApi "Components" {
            include *
            autoLayout
        }

        styles {
            # element <tag> {}
            element "User" {
                background #08427B
                color #ffffff
                fontSize 22
                shape Person
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            relationship "Relationship" {
                dashed false
            }
            element "Database" {
                shape Cylinder
            }
            relationship "Async Request" {
                dashed true
            }
        }

        theme default
    }

}