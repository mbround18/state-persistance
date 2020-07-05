locals {

    global_tags = merge(var.tags, {
        Project = var.project
        Region  = var.aws_region
    })

}