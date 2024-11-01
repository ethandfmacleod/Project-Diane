import json
import boto3
import os

s3_client = boto3.client('s3')
transcribe_client = boto3.client('transcribe')
sns_client = boto3.client('sns')

def handler(event, context):
    bucket_name = os.environ['S3_BUCKET_NAME']
    file_key = event['Records'][0]['s3']['object']['key']
    job_name = file_key.split('/')[-1].split('.')[0]

    response = transcribe_client.start_transcription_job(
        TranscriptionJobName=job_name,
        Media={'MediaFileUri': f's3://{bucket_name}/{file_key}'},
        MediaFormat='wav',
        LanguageCode='en-US',
        OutputBucketName=bucket_name,
        OutputKey=f'transcriptions/{job_name}.json'
    )
    
    # Wait for the transcription job to complete
    job_status = ''
    while job_status != 'COMPLETED':
        status = transcribe_client.get_transcription_job(TranscriptionJobName=job_name)
        job_status = status['TranscriptionJob']['TranscriptionJobStatus']
    
    # Send notification via SNS
    sns_client.publish(
        TopicArn=os.environ['SNS_TOPIC_ARN'],
        Message=f'Transcription job {job_name} has completed successfully.',
        Subject='Transcription Job Completed'
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Transcription job started')
    }
