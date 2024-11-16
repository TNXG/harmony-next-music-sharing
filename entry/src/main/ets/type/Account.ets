/**
 * 账号信息相关类型
 */
export interface AccountProfile {
  userId: number
  nickname: string
  avatarUrl: string
  backgroundUrl: string
}

export interface Account {
  id: number
  userName: string
}