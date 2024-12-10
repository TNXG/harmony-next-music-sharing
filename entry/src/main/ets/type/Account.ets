/**
 * 账号信息相关类型
 */
export interface AccountProfile {
  userId: number
  nickname: string
  avatarUrl: string
  backgroundUrl: string
  vipType: number
}

export interface Account {
  id: number
  userName: string
}

@Observed
class LoginStatus {
  code: number = 0
  message: string = ''
  cookie?: string = ''
}

export interface LoginStatusResponse {
  data: LoginStatus
}

export interface RefreshForm {
  cookie: string,
  crypto:string
}