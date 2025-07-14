export class GoalItem {
  id: number;
  sportName: string;
  type: string;
  duration: number;
  status: string;

  constructor(id: number = 0, sportName: string = '', type: string = '', duration: number = 0, status: string = '') {
    this.id = id;
    this.sportName = sportName;
    this.type = type;
    this.duration = duration;
    this.status = status;
  }
}