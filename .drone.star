config = {
	'name': 'cs3api-validator',
	'rocketchat': {
		'channel': 'builds',
		'from_secret': 'private_rocketchat'
	},
	'branches': [
		'main'
	],
}

def main(ctx):
	before = beforePipelines(ctx)
	if (before == False):
		print('Errors detected. Review messages above.')
		return []
	stages = stagePipelines(ctx)
	if (stages == False):
		print('Errors detected. Review messages above.')
		return []
	dependsOn(before, stages)
	after = afterPipelines(ctx)
	dependsOn(stages, after)
	return before + stages + after

def beforePipelines(ctx):
	return linting(ctx)

def stagePipelines(ctx):
	return tests(ctx)

def afterPipelines(ctx):
	return [
		notify()
	]

def dependsOn(earlierStages, nextStages):
	for earlierStage in earlierStages:
		for nextStage in nextStages:
			nextStage['depends_on'].append(earlierStage['name'])

def notify():
	result = {
		'kind': 'pipeline',
		'type': 'docker',
		'name': 'chat-notifications',
		'clone': {
			'disable': True
		},
		'steps': [
			{
				'name': 'notify-rocketchat',
				'image': 'plugins/slack:1',
				'pull': 'always',
				'settings': {
					'webhook': {
						'from_secret': config['rocketchat']['from_secret']
					},
					'channel': config['rocketchat']['channel']
				}
			}
		],
		'depends_on': [],
		'trigger': {
			'ref': [
				'refs/tags/**'
			],
			'status': [
				'success',
				'failure'
			]
		}
	}

	for branch in config['branches']:
		result['trigger']['ref'].append('refs/heads/%s' % branch)

	return result

def linting(ctx):
	pipelines = []

	result = {
		'kind': 'pipeline',
		'type': 'docker',
		'name': 'lint',
		'steps': [
			{
			"name": "validate-go",
			"image": "golangci/golangci-lint:latest",
			"commands": [
				"golangci-lint run -v",
			]
			},
		],
		'depends_on': [],
		'trigger': {
			'ref': [
				'refs/pull/**',
				'refs/tags/**'
			]
		}
	}

	for branch in config['branches']:
		result['trigger']['ref'].append('refs/heads/%s' % branch)

	pipelines.append(result)

	return pipelines

def tests(ctx):
	pipelines = []
	result = {
		'kind': 'pipeline',
		'type': 'docker',
		'name': 'test-acceptance-cs3api',
		'steps': [
			{
				"name": "test",
				"image": "owncloudci/golang:1.17",
				"commands": [
					"go test -v",
				],
				"volumes": [
					{
						"name": "gopath",
						"path": "/go",
					}
				],
			},
		],
		'depends_on': [],
		'trigger': {
			'ref': [
				'refs/tags/**',
				'refs/pull/**',
			]
		}
	}

	for branch in config['branches']:
		result['trigger']['ref'].append('refs/heads/%s' % branch)

	pipelines.append(result)

	return pipelines
