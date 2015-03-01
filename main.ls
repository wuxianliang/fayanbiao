
import prelude
if Meteor.isClient
	Session.setDefault 'inputStatus', 'plus'
	Router.route '/', ->
		@render 'Home', {data: {title: '发言记录表'}}
	Template.home.rendered = ->
		$('.ui.checkbox').checkbox!

		new ViewModel({
			addNew: ->
				@new !@new!
			new: false
			className: ''
			switchPlusMinus: ->
				status = Session.get 'inputStatus'
				if status == 'plus'
					Session.set 'inputStatus', 'minus'
				else
					Session.set 'inputStatus', 'plus'
			addNewClass: ->
				id = Classes.insert {
					owner: Meteor.userId!
					className: @className!
				}
				if Lessons.find({classId: id}).count! is 0
					for i in [0 to 44]
						Lessons.insert {
							owner: Meteor.userId!
							classId: id
							index: i+1
							name: i+1
							date: moment!.format 'YYYY-MM-DD'
						}
				@className ''

			name: ''
			nameIsFocused: false
			number: ''
			numberIsFocused: false
			switchFocus: ->
				@numberIsFocused !@numberIsFocused!
				@nameIsFocused !@nameIsFocused!
			color: (number)->
				switch number
				| 0 => '#ededed'
				| 1 => '#dae289'
				| 2 => '#9cc069'
				| 3 => '#669d45'
			addNewStudent:->
				if Session.get 'classId'
					id = Students.insert {
						owner: Meteor.userId!
						classId: Session.get 'classId'
						name: @name!
						number: Number @number!
					}

					for i in [1 to 45]
						Scores.insert {
							studentId: id
							classId: Session.get 'classId'
							lessonIndex: i
							rank0: 0
							rank0color: @color 0
							rank1: 0
							rank1color: @color 0
							rank2: 0
							rank2color: @color 0
							rank3: 0
							rank3color: @color 0
						}
					@name ''
					@number ''
					@switchFocus!
				else
					alert '请先选定班级'
		}).bind @

	Template.ban.rendered = ->
		($ '.menu .item').tab!
		new ViewModel(@data).extend({
			selectClassId: ->
				Session.set 'classId', @_id!

		}).bind @
	Template.spreadsheet.created = ->
		@vm = new ViewModel({
			classes: ->
				Classes.find {owner: Meteor.userId!}
		}).addHelper 'classes', @

	Template.spreadsheet.rendered = ->
		($ '.menu .item').tab!
		@vm.bind @

	Template.table.created = ->
		@vm = new ViewModel(@data).extend(



			students: ->
				Students.find {owner: Meteor.userId!, classId: Session.get 'classId' },{sort:{number:1}}

			lessons: ->
				Lessons.find {owner: Meteor.userId!, classId: Session.get 'classId'},{sort:{index:1}}

		).addHelpers ['lessons' 'students'], @

	Template.table.rendered  = ->
		($ '.menu .item').tab!
		@vm.bind @
	Template.lesson.rendered = ->
		new ViewModel(@data).extend(
			showLessonReport: ->
				Session.set 'lessonId', @_id!
				SemanticModal.generalModal 'lessonReport', {  }
		).bind @
	Template.lessonReport.created = ->
				@vm = new ViewModel('lessonreport', {

					id: ->
						Session.get 'lessonId'
					isFocused:false
					newName: ->
						Lessons.findOne(@id!).name
					lessonIndex: ->
						Lessons.findOne(@id!).index
					name: ''
					showName: true
					changeName: false

					showTime: true
					inputTime: false
					teachTime: ''
					date: ->
						Lessons.findOne(@id!).date
					switch:->
						@teachTime ''
						@showTime !@showTime!
						@inputTime !@inputTime!
						@isFocused !@isFocused!


					updateTime: ->
						Lessons.update @id!, {$set: {date: @teachTime!}}
						@teachTime ''
						@showTime !@showTime!
						@inputTime !@inputTime!
						@isFocused !@isFocused!
					change: ->
						@name ''
						@showName !@showName!
						@changeName !@changeName!
						@isFocused !@isFocused!

					updateName: ->
						Lessons.update @id!, {$set: { name: @name!}}
						@name ''
						@showName !@showName!
						@changeName !@changeName!
						@isFocused !@isFocused!

					showRanks: true
					showDetails: false
					switchCanvas: ->
						@showRanks !@showRanks!
						@showDetails !@showDetails!
					rank0:->
						sum map (.rank0), Scores.find({lessonIndex: @lessonIndex!, classId: Session.get 'classId'}).fetch!
					rank1:->
						sum map (.rank1), Scores.find({lessonIndex: @lessonIndex!, classId: Session.get 'classId'}).fetch!
					rank2:->
						sum map (.rank2), Scores.find({lessonIndex: @lessonIndex!, classId: Session.get 'classId'}).fetch!
					rank3:->
						sum map (.rank3), Scores.find({lessonIndex: @lessonIndex!, classId: Session.get 'classId'}).fetch!
					barData: -> {
						labels: ["0", "1", "2", "3"],
						datasets: [
							{
								label: @newName!,
								fillColor: "rgba(151,187,205,0.5)",
								strokeColor: "rgba(151,187,205,0.8)",
								highlightFill: "rgba(151,187,205,0.75)",
								highlightStroke: "rgba(151,187,205,1)",
								data: [@rank0!, @rank1!, @rank2!, @rank3!]
							}]
						}
					amountOfStudents: ->
						Students.find({owner: Meteor.userId!, classId: Session.get 'classId'}).count!
					rank00: ->
						amountOfRank0 = (filter (> 0), map (.rank0), Scores.find({lessonIndex: @lessonIndex!, classId: Session.get 'classId'}).fetch!).length
						(amountOfRank0 / @amountOfStudents!).toFixed(3)
					rank11: ->
						amountOfRank1 = (filter (> 0), map (.rank1), Scores.find({lessonIndex: @lessonIndex!, classId: Session.get 'classId'}).fetch!).length
						(amountOfRank1 / @amountOfStudents!).toFixed(3)
					rank22: ->
						amountOfRank2 = (filter (> 0), map (.rank2), Scores.find({lessonIndex: @lessonIndex!, classId: Session.get 'classId'}).fetch!).length
						(amountOfRank2 / @amountOfStudents!).toFixed(3)
					rank33: ->
						amountOfRank3 = (filter (> 0), map (.rank3), Scores.find({lessonIndex: @lessonIndex!, classId: Session.get 'classId'}).fetch!).length
						(amountOfRank3 / @amountOfStudents!).toFixed(3)
					percentData: -> {
						labels: ["0", "1", "2", "3"],
						datasets: [
							{
								label: @newName!,
								fillColor: "rgba(191,187,205,0.5)",
								strokeColor: "rgba(191,187,205,0.8)",
								highlightFill: "rgba(191,187,205,0.75)",
								highlightStroke: "rgba(191,187,205,1)",
								data: [@rank00!, @rank11!, @rank22!, @rank33!]
							}]
						}


					options:{}
				}).addHelpers ['newName' 'date'], @
	Template.lessonReport.rendered = ->
				@vm.bind @

				ranks = $("#"+"ranks").get(0).getContext "2d"
				rankChart = new Chart(ranks).Bar(@vm.barData!, @vm.options!)
				details = $("#"+"details").get(0).getContext "2d"
				detailsChart = new Chart(details).Bar(@vm.percentData!, @vm.options!)
	Template.student.created = ->
		@vm = new ViewModel(@data).extend(
			showDelete:false
			deleteStudent:->
				Students.remove @_id!
			scores: -> Scores.find {studentId: @_id! },{sort:{lessonIndex:1}}
			showStudentReport: ->
				Session.set 'studentId', @_id!
				SemanticModal.generalModal 'studentReport', { id: @_id! }

		).addHelper 'scores', @

	Template.student.rendered = ->
		@vm.bind @
	Template.score.created = ->
		@vm = new ViewModel(@data).extend({

			plusOne: (rank) ->
				status = Session.get 'inputStatus'
				if status == 'plus'
					switch rank
					case 'rank0'
						Scores.update @_id!, {$inc: { rank0: 1 }}
					case 'rank1'
						rank1 = Scores.findOne(@_id!).rank1
						if rank1 == -1
							Scores.update @_id!, {$set: {rank1color: '#ededed' }, $inc: { rank1: 1 }}
						else
							Scores.update @_id!, {$set: {rank1color: '#dae289' }, $inc: { rank1: 1 }}
					case 'rank2'
						rank2 = Scores.findOne(@_id!).rank2
						if rank2 == -1
							Scores.update @_id!, {$set: {rank2color: '#ededed' }, $inc: { rank2: 1 }}
						else
							Scores.update @_id!, {$set: {rank2color: '#9cc069' }, $inc: { rank2: 1 }}

					case 'rank3'
						rank3 = Scores.findOne(@_id!).rank3
						if rank3 == -1
							Scores.update @_id!, {$set: {rank3color: '#ededed' }, $inc: { rank3: 1 }}
						else
							Scores.update @_id!, {$set: {rank3color: '#669d45' }, $inc: { rank3: 1 }}

				else if status == 'minus'
					switch rank
					case 'rank0'
						Scores.update @_id!, {$inc: { rank0: -1 }}
					case 'rank1'
						rank1 = Scores.findOne(@_id!).rank1
						if rank1 == 1
							Scores.update @_id!, {$set: {rank1color: '#ededed' }, $inc: { rank1: -1 }}
						else
							Scores.update @_id!, {$set: {rank1color: '#dae289' }, $inc: { rank1: -1 }}
					case 'rank2'
						rank2 = Scores.findOne(@_id!).rank2
						if rank2 == 1
							Scores.update @_id!, {$set: {rank2color: '#ededed' }, $inc: { rank2: -1 }}
						else
							Scores.update @_id!, {$set: {rank2color: '#9cc069' }, $inc: { rank2: -1 }}

					case 'rank3'
						rank3 = Scores.findOne(@_id!).rank3
						if rank3 == 1
							Scores.update @_id!, {$set: {rank3color: '#ededed' }, $inc: { rank3: -1 }}
						else
							Scores.update @_id!, {$set: {rank3color: '#669d45' }, $inc: { rank3: -1 }}

			score: -> Scores.findOne @_id!
			rank: (rank) ->
				switch rank
				case 'rank0'
					if @score!.rank0 == 0
						return ''
					else
						@score!.rank0
				case 'rank1'
					if @score!.rank1 == 0
						return ''
					else
						@score!.rank1
				case 'rank2'
					if @score!.rank2 == 0
						return ''
					else
						@score!.rank2
				case 'rank3'
					if @score!.rank3 == 0
						return ''
					else
						@score!.rank3
		})
	Template.score.rendered  = ->
		@vm.bind @
	Template.studentReport.created  = ->
		@vm = new ViewModel('studentreport', {
			id: ->
				Session.get 'studentId'
			name: ->
				Students.findOne(@id!).name

			rank0:->
				sum map (.rank0), Scores.find({studentId: @id!}).fetch!

			rank1:->
				sum map (.rank1), Scores.find({studentId: @id!}).fetch!
			rank2:->
				sum map (.rank2), Scores.find({studentId: @id!}).fetch!
			rank3:->
				sum map (.rank3), Scores.find({studentId: @id!}).fetch!
			studentData: -> {
				labels: ["0", "1", "2", "3"],
				datasets: [
					{
							label: @name!,
							fillColor: "rgba(151,187,205,0.5)",
							strokeColor: "rgba(151,187,205,0.8)",
							highlightFill: "rgba(151,187,205,0.75)",
							highlightStroke: "rgba(151,187,205,1)",
							data: [@rank0!, @rank1!, @rank2!, @rank3!]
					}]
				}
			options:{}
		}).addHelper 'name', @
	Template.studentReport.rendered = ->
		@vm.bind @
		ranks = $("#"+"student").get(0).getContext "2d"
		rankChart = new Chart(ranks).Bar(@vm.studentData!, @vm.options!)
if Meteor.isServer
	Meteor.startup ->
