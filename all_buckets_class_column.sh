#!/bin/bash

# Function to print CSV row
print_row_csv() {
    printf "%s,%s,%s,%s,%s,%s,%s,%s\n" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
}

# Output file name
output_file="s3_bucket_sizes.csv"

# Print CSV header
echo "Bucket Name,Region,STANDARD,STANDARD_IA,GLACIER,INTELLIGENT_TIERING,ONEZONE_IA,GLACIER_DEEP_ARCHIVE" > "$output_file"

# Iterate over each region
for region in "us-west-2" "ca-central-1"; do
    # Get list of S3 buckets in the current region
    buckets=$( aws s3api list-buckets --query "Buckets[].Name" --output text --region "$region")
    echo "processing bucket before loop: $bucket_name"
   for bucket_name in $buckets; do
	echo "processing bucket: $bucket_name"        
	# Get the size of objects in each storage class
        standard_size=$(aws s3api list-objects-v2 --bucket "$bucket_name" --query "sum(Contents[?StorageClass=='STANDARD'].Size)" --output text --region "$region" 2>/dev/null)
        total_standard_size=0
	for size in $standard_size; do
		total_standard_size=$((total_standard_size + size))
	done
	echo "total_standard_size: $total_standard_size"
	standard_size_gb=$(echo "scale=1; $total_standard_size / 1073741824" | bc)
        
	standard_ia_size=$(aws s3api list-objects-v2 --bucket "$bucket_name" --query "sum(Contents[?StorageClass=='STANDARD_IA'].Size)" --output text --region "$region" 2>/dev/null)
        for size in $standard_ia_size; do
		total_standard_ia_size=$((total_standard_ia_size + size))
	done
	echo "total_standard_ia_size: $total_standard_ia_size"
	standard_ia_size_gb=$(echo "scale=1; $total_standard_ia_size / 1073741824" | bc)

        glacier_size=$(aws s3api list-objects-v2 --bucket "$bucket_name" --query "sum(Contents[?StorageClass=='GLACIER'].Size)" --output text --region "$region" 2>/dev/null)
	for size in $glacier_size; do
		total_glacier_size=$((total_glacier_size + size))
	done
	echo "total_glacier_size: $total_glacier_size"
	glacier_size_gb=$(echo "scale=1; $total_glacier_size / 1073741824" | bc)

        intelligent_tiering_size=$(aws s3api list-objects-v2 --bucket "$bucket_name" --query "sum(Contents[?StorageClass=='INTELLIGENT_TIERING'].Size)" --output text --region "$region" 2>/dev/null)
	for size in $intelligent_tiering_size; do
		total_intelligent_tiering_size=$((total_intelligent_tiering_size + size))
	done
	echo "total_intelligent_tiering_size: $total_intelligent_tiering_size"
	intelligent_tiering_size_gb=$(echo "scale=1; $total_intelligent_tiering_size / 1073741824" | bc)

        onezone_ia_size=$(aws s3api list-objects-v2 --bucket "$bucket_name" --query "sum(Contents[?StorageClass=='ONEZONE_IA'].Size)" --output text --region "$region" 2>/dev/null)
	for size in $onezone_ia_size; do
		total_onezone_ia_size=$((total_onezone_ia_size + size))
	done
	echo "total_onezone_ia_size: $total_onezone_ia_size"
        onezone_ia_size_gb=$(echo "scale=1; $total_onezone_ia_size / 1073741824" | bc)

        glacier_deep_archive_size=$(aws s3api list-objects-v2 --bucket "$bucket_name" --query "sum(Contents[?StorageClass=='GLACIER_DEEP_ARCHIVE'].Size)" --output text --region "$region" 2>/dev/null)
	for size in $glacier_deep_archive_size; do
		total_glacier_deep_archive_size=$((total_glacier_deep_archive_size + size))
	done
	echo "total_glacier_deep_archive_size: $total_glacier_deep_archive_size"
        glacier_deep_archive_size_gb=$(echo "scale=1; $total_glacier_deep_archive_size / 1073741824" | bc)

        # Print CSV row for the current bucket
        print_row_csv "$bucket_name" "$region" "$standard_size_gb" "$standard_ia_size_gb" "$glacier_size_gb" "$intelligent_tiering_size_gb" "$onezone_ia_size_gb" "$glacier_deep_archive_size_gb" >> "$output_file"
    done
done
