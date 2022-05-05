import FLOATEventsBook from "../FLOATEventsBook.cdc"

pub let STATE_TODO = "todo"
pub let STATE_READY = "ready"
pub let STATE_ACCOMPLISHED = "accomplished"

pub struct GoalStatus {
  // user status
  pub let status: String
  // info 
  pub let identifer: String
  pub let title: String
  pub let points: UInt64
  pub let detail: {String: AnyStruct}

  init(
    status: String,
    identifer: String,
    title: String,
    points: UInt64,
    detail: {String: AnyStruct}
  ) {
    self.status = status
    self.identifer = identifer
    self.title = title
    self.points = points
    self.detail = detail
  }
}

pub fun main(
  accountAddr: Address,
  host: Address,
  bookId: UInt64
): [GoalStatus] {
  let acct = getAccount(accountAddr)

  let achievementBoard = acct
    .getCapability(FLOATEventsBook.FLOATAchievementBoardPublicPath)
    .borrow<&FLOATEventsBook.AchievementBoard{FLOATEventsBook.AchievementBoardPublic}>()
    ?? panic("Failed to borrow achievement board")

  let record = achievementBoard.borrowAchievementRecordRef(host: host, bookId: bookId)
    ?? panic("Failed to borrow achievement record")

  let finishedGoals = record.getFinishedGoals()

  let eventsBookRef = record.getTarget().getEventsBookPublic()
  let goals = eventsBookRef.getGoals()
  let goalLen = goals.length

  let ret: [GoalStatus] = []
  var i = 0
  while i < goalLen {
    let goal = goals[i]

    var status = STATE_TODO
    if finishedGoals.contains(i) {
      status = STATE_ACCOMPLISHED
    } else if record.isGoalReady(goalIdx: i) {
      status = STATE_READY
    }

    ret.append(GoalStatus(
      status: status,
      identifer: goal.getType().identifier,
      title: goal.title,
      points: goal.getPoints(),
      detail: goal.getGoalDetail()
    ))
    i = i + 1
  }
  return ret
}