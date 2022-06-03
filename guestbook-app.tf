resource "kubernetes_deployment" "redis-slave" {
   metadata {
    name = "redis-slave"
    labels = {
       app = "guestbook"
       role = "slave"
       tier = "backend"
    }
   }
   spec {
      replicas =  2
      selector {
         match_labels = {
            app = "guestbook"
            role = "slave"
            tier = "backend"
         }
      }
      template {
        metadata {
          labels = {
            app = "guestbook"
            role = "slave"
            tier = "backend"
          }
        }
        spec {
          container {
             name = "slave"
             image = "gcr.io/google_samples/gb-redisslave:v1"

             resources {
                requests = {
                   cpu = "100m"
                   memory = "100Mi"
                 }
             }
             port {
                container_port =  6379
             }
          }
       }
     }
   }
 }

resource "kubernetes_deployment" "redis-master" {
  metadata {
    name = "redis-master"
    labels = {
       app = "guestbook"
       role = "master"
       tier = "backend"
    }
  }
  spec {
      replicas =  2
      selector {
         match_labels = {
            app = "guestbook"
            role = "master"
            tier = "backend"
         }
      }
      template {
        metadata {
          labels = {
            app = "guestbook"
            role = "master"
            tier = "backend"
          }
        }
        spec {
          container {
             name = "master"
             image = "gcr.io/google_containers/redis:e2e"

             resources {
                requests = {
                   cpu = "100m"
                   memory = "100Mi"
                 }
             }
             port {
                container_port =  6379
             }
          }
       }
     }
   }
 }

resource "kubernetes_service" "redis-slave" {
  metadata {
    name = "redis-slave"
    labels = {
       app = "guestbook"
       role = "master"
       tier = "backend"
    }
  }
  spec {
    port {
      port        = 6379
    }
    selector = {
      app = "guestbook"
      role = "master"
      tier = "backend"
    }
  }
}
resource "kubernetes_service" "redis-master" {
  metadata {
    name = "redis-master"
    labels = {
       app = "guestbook"
       role = "master"
       tier = "backend"
    }
  }
  spec {
    port {
      port        = 6379
    }
    selector = {
      app = "guestbook"
      role = "master"
      tier = "backend"
    }
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
    labels = {
       app = "guestbook"
       tier = "frontend"
    }
  }
  spec {
      replicas =  3
      selector {
         match_labels = {
            app = "guestbook"
            tier = "frontend"
         }
      }
      template {
        metadata {
          labels = {
            app = "guestbook"
            tier = "frontend"
          }
        }
        spec {
          container {
             name = "php-redis"
             image = "gcr.io/google-samples/gb-frontend:v4"

             resources {
                requests = {
                   cpu = "100m"
                   memory = "100Mi"
                 }
             }
             port {
                container_port =  80
             }
          }
       }
     }
   }
 }

resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"
    labels = {
       app = "guestbook"
       tier = "frontend"
    }
  }
  spec {
    port {
      port        = 80
    }
    selector = {
      app = "guestbook"
      tier = "frontend"
    }
    type = "LoadBalancer"
  }
}
output "guestbook_load_balancer_host" {
  value = kubernetes_service.frontend.status[0].load_balancer[0].ingress[0].hostname
}
