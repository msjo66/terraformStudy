output "two_regions_with_zones" {
  value       = [for v in module.regions.regions : v if contains(random_shuffle.two_region_names_with_zones.result, v.name)]
  description = "Outputs two random regions with zones in the input."
}